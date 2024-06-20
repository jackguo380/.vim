#! /usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptionsFromArray);
use Term::ANSIColor;
use File::Spec::Functions qw(canonpath file_name_is_absolute);
use File::Basename;
use List::MoreUtils qw(first_index);

eval 'use JSON';
if ($@) {
    die "Cannot load JSON library ($@), install it: \$ cpan JSON";
}

my %COMMANDS_MAP = (
    'help' => \&helpcommand,
    'addflag' => \&addflagcommand,
    'rmflag' => \&rmflagcommand,
    'lsflag' => \&lsflagcommand,
    'abspath' => \&abspathcommand,
    'join' => \&joincommand,
    'dumpcmd' => \&dumpcmdcommand,
    'gcccrosscompile' => \&gcccrosscompilecommand,
    #    'globalflags' => \&globalflagscommand
);

my $COMMANDS = "
help     - get help for a specific command
addflag  - add a compile flag to the database
rmflag   - remove a compile flag from the database
lsflag   - lookup flags matching a regex
abspath  - make flags with paths absolute
join     - join multiple compile databases together
dumpcmd  - dump the command for files matching a regex
gcccrosscompile - add flags for cross compilation
";
# globalflags - create a global set of flags

if(not @ARGV) {
    usage();
    exit 1;
} else {
    my $cmd = shift @ARGV;

    if (defined($COMMANDS_MAP{$cmd})) {
        &{$COMMANDS_MAP{$cmd}}(@ARGV);
        exit 0;
    } else {
        print STDERR colored("Unknown command: $cmd\n", "red")
        unless($cmd eq "-h" or $cmd eq "--help");

        usage();
        exit 1;
    }
}


sub is_help {
    for(@_) {
        if ($_ eq "-h" or $_ eq "--help") {
            return 1;
        }
    }

    return 0;
}

sub usage {
    print STDERR "
Clang compilation database manipulation tool

Can be used to modify a compile_commands.json database

Usage:
compiledbtool.pl <command> [<args to command..>]

Commands:
$COMMANDS
";
}

sub helpcommand {
    my @args = @_;
    if(@args < 1 or is_help(@args)) {
        print STDERR "
Usage:
compiledbtool.pl help <command>

Commands:
$COMMANDS
";
    } elsif (defined($COMMANDS_MAP{$args[0]})) {
        &{$COMMANDS_MAP{$args[0]}}('--help');
        exit 0;
    }
}

sub addflagcommand {
    my @args = @_;

    if (is_help(@args)) {
        print STDERR "
Add the flag to all files in the database.

Usage:
compiledbtool.pl addflag [<options>] <flag>

Options:
None so far...
";
        exit 0;
    }

    die "A flag is required" if (@args < 1);

    my $flag = $args[0];
    my $cdb = readcdb();

    for my $command (@$cdb) {
        my $curfile = $command->{"file"};

        if(not defined $command->{"arguments"}) {
            my $commandstr = $command->{"command"};
            my @commandarr = split(/[ \t]+/, $commandstr);
            $command->{"arguments"} = \@commandarr;
            delete $command->{"command"};
        }

        print STDERR colored($curfile, "yellow"), ": Adding $flag\n";
        push @{$command->{"arguments"}}, $flag;
    }

    writecdb($cdb);
}

sub rmflagcommand {
    my @args = @_;

    if (is_help(@args)) {
        print STDERR "
Remove all flags matching <regex>

Usage:
compiledbtool.pl rmflag [<options>] <regex>

Options:
None so far...
";
        exit 0;
    }

    die "A regex is required" if (@args < 1);

    my $regex = qr/($args[0])/;
    my $cdb = readcdb();

    for my $command (@$cdb) {
        my $curfile = $command->{"file"};

        if(not defined $command->{"arguments"}) {
            my $commandstr = $command->{"command"};
            my @commandarr = split(/[ \t]+/, $commandstr);
            $command->{"arguments"} = \@commandarr;
            delete $command->{"command"};
        }

        my @remlist;

        for my $idx (0 .. @{$command->{"arguments"}} - 1) {
            if($command->{"arguments"}[$idx] =~ $regex) {
                print STDERR colored($curfile, "yellow"), ": Removing $1\n";
                push @remlist, $idx;
            }
        }

        # Must do this in reverse so indexs don't get invalidated
        for my $idx (reverse @remlist) {
            splice @{$command->{"arguments"}}, $idx, 1;
        }
    }

    writecdb($cdb);
}

sub lsflagcommand {
    my @args = @_;

    if (is_help(@args)) {
        print STDERR "
List all flags matching <regex>

Usage:
compiledbtool.pl lsflag [<options>] <regex>

Options:
--before N  - Number of arguments to display before matched argument
--after N   - Number of arguments to display after matched argument
";
        exit 0;
    }

    die "A regex is required" if (@args < 1);

    my $regex = qr/$args[0]/;

    shift @args;

    # TODO: implement this
    my $nbefore = '0';
    my $nafter = '0';

    GetOptionsFromArray(\@args,
        'before=i' => \$nbefore,
        'after=i' => \$nafter
    ) or die "Failed to parse options";

    my $cdb = readcdb();

    for my $command (@$cdb) {
        my $curfile = $command->{"file"};

        if(not defined $command->{"arguments"}) {
            my $commandstr = $command->{"command"};
            my @commandarr = split(/[ \t]+/, $commandstr);
            $command->{"arguments"} = \@commandarr;
            delete $command->{"command"};
        }

        for my $arg (@{$command->{"arguments"}}) {
            if($arg =~ $regex) {
                print colored($curfile, "yellow"), ": $arg\n";
            }
        }
    }
}

sub abspathcommand {
    my @args = @_;

    if (is_help(@_)) {
        print STDERR "
Change relative paths to absolute paths.
if --working-directory is given don't modify flags but just
add -working-directory for all files.

Usage:
compiledbtool.pl abspath [<options>]

Options:
--working-directory - use Clang's -working-directory flag
";
        exit 0;
    }

    my $useworkdir = 0;

    GetOptionsFromArray(\@args,
        'working-directory' => \$useworkdir
    ) or die "Failed to parse options";

    my $cdb = readcdb();

    for my $command (@$cdb) {
        my $curfile = $command->{"file"};
        my $curdir = $command->{"directory"};

        if(not defined $command->{"arguments"}) {
            my $commandstr = $command->{"command"};
            my @commandarr = split(/[ \t]+/, $commandstr);
            $command->{"arguments"} = \@commandarr;
            delete $command->{"command"};
        }

        if($useworkdir) {
            push @{$command->{"arguments"}}, "-working-directory";
            push @{$command->{"arguments"}}, $curdir;
            print STDERR colored($curfile, "yellow"), ": Adding -working-directory $curdir\n";
        } else {
            my $next_is_path = 0;

            for my $idx (0 .. @{$command->{"arguments"}} - 1) {
                if($next_is_path) {
                    my $path = $command->{"arguments"}[$idx];
                    if(!file_name_is_absolute($path)) {
                        $command->{"arguments"}[$idx] = canonpath($curdir . "/" . $path);
                    }
                    $next_is_path = 0;
                } else {
                    my $arg = $command->{"arguments"}[$idx];
                    my $flag;
                    if($arg =~ /^-I(.*)/) {
                        $flag = "-I";
                    } elsif($arg =~ /^-isystem(.*)/) {
                        $flag = "-isystem";
                    } elsif($arg =~ /^-iquote(.*)/) {
                        $flag = "-iquote";
                    } elsif($arg =~ /^--sysroot=(.*)/) {
                        $flag = "--sysroot";
                    } elsif($arg =~ /^-include(.*)/) {
                        $flag = "-include";
                    } else {
                        next;
                    }

                    if(length($1) > 0) {
                        if(!file_name_is_absolute($1)) {
                            $command->{"arguments"}[$idx] = $flag . canonpath($curdir . "/" . $1);
                        }
                    } else {
                        $next_is_path = 1;
                    }

                    print STDERR colored($curfile, "yellow"), ": Making $flag absolute\n";
                }
            }
        }
    }

    writecdb($cdb);
}

sub joincommand {
    my @args = @_;

    if (is_help(@_)) {
        print STDERR "
Join multiple compile_commands.json together
The last filename is the output.

Usage:
compiledbtool.pl join [<options>] <cdb1> <cdb2> [<cdb3> ...] <cdbout>

Options:
None so far...
";
        exit 0;
    }
    
    if(@args < 2) {
        die "Specify atleast 2 files";
    }

    my @joinedcdb;

    for my $cdbfile (@args[0..-2]) {
        push @joinedcdb, @{readcdb($cdbfile)};
    }

    if(-f $args[-1]) {
        push @joinedcdb, @{readcdb($args[-1])};
    }

    writecdb(\@joinedcdb);
}

sub globalflagscommand {
    my @args = @_;

    if (is_help(@_)) {
        print STDERR "
Find all compile flags in database

Usage:
compiledbtool.pl globalflags

Options:
None so far...
";
        exit 0;
    }

    my %flaghash;

    my $cdb = readcdb();

    for my $command (@$cdb) {
        my $flags = $command->{"arguments"};

        if(not defined $command->{"arguments"}) {
            my $commandstr = $command->{"command"};
            my @commandarr = split(/[ \t]+/, $commandstr);
            $command->{"arguments"} = \@commandarr;
            delete $command->{"command"};
        }

        for my $flag (@$flags) {
            if (!defined($flaghash{$flag})) {
                $flaghash{$flag} = 0;
            }

            $flaghash{$flag} += 1;
        }
    }

    for my $flag (keys %flaghash) {
        print "$flag\t\t$flaghash{$flag}";
    }
}

sub dumpcmdcommand {
    my @args = @_;

    if (is_help(@_)) {
        print STDERR "
Dump the full command used for compiling.
This can be useful to test compile a source file to see the errors.

Usage:
compiledbtool.pl dumpcmd <source file regex>

Options:
None
";
        exit 0;
    }

    if (@args < 1) {
        print STDERR "Please specify a regex\n";
        exit 1;
    }
    my $regex = qr/$args[0]/;

    my $cdb = readcdb();

    my @match_commands;

    for my $command (@$cdb) {
        my $file = $command->{"file"};

        if ($file =~ $regex) {
            push @match_commands, $command;
        }
    }

    if (@match_commands == 1) {
        print join(' ', @{$match_commands[0]->{"arguments"}}), "\n";
    } elsif (@match_commands == 0) {
        print STDERR colored("No files match the regex\n", "red");
    } else {
        for my $command (@match_commands) {
            print colored($command->{"file"}, "yellow"), ": ", join(' ', @{$command->{"arguments"}}), "\n";
        }
    }
}

sub gcccrosscompilecommand {
    my @args = @_;

    if (is_help(@_)) {
        print STDERR "
Add common libclang flags for cross compiling
this tries to run the cross compiler and checks the filesystem to determine
extra flags and includes needed for cross compiling.

It is important that the generated database contains the path to the cross compiler as the first argument.

Usage:
compiledbtool.pl gcccrosscompile

Options:
None
";
        exit 0;
    }

    my $cdb = readcdb();

    my %compiler_cache;

    for my $command (@$cdb) {
        if(not defined $command->{"arguments"}) {
            my $commandstr = $command->{"command"};
            my @commandarr = split(/[ \t]+/, $commandstr);
            $command->{"arguments"} = \@commandarr;
            delete $command->{"command"};
        }

        my $arguments = $command->{"arguments"};
        my $compiler = $arguments->[0];

        if ($compiler =~ qr/^[^-].*g?[c+][c+]/) {
            print STDERR colored($command->{"file"}, "yellow"), ": Compiler = $compiler\n";

            if (not defined $compiler_cache{$compiler}) {
                my @flags = cross_compile_flags($compiler, $command);
                $compiler_cache{$compiler} = \@flags;
            }

            print STDERR colored($command->{"file"}, "yellow"), ": Flags = ", join(",", @{$compiler_cache{$compiler}}), "\n";

            push @{$command->{"arguments"}}, @{$compiler_cache{$compiler}};
        }
    }

    writecdb($cdb);
}

sub cross_compile_flags {
    my $compiler = $_[0];
    my $command = $_[1];
    my @flags;

    `$compiler --version`;
    
    if ($? == 0) {
        my $arch = `$compiler -dumpmachine`;

        push @flags, "--target=$arch" unless ($arch eq "");

        my $libgcc = `$compiler -print-libgcc-file-name`;
        my $toolchain = dirname(dirname(dirname(dirname(dirname($libgcc)))));

        push @flags, "--gcc-toolchain=$toolchain";

        my $sysroot = `$compiler -print-sysroot`;

        push @flags, "--sysroot=$sysroot";

        my ($stdinc, $stdinc_cpp) = command_stdinc($command);

        if ($stdinc) {
            # Don't use -x c since we may have a g++ compiler in some cases
            my $xcpp_flag = $stdinc_cpp ? "-xc++" : "";
            my $is_system_inc = 0;

            for my $inc_line (split /^/m, `$compiler -E $xcpp_flag -Wp,-v /dev/null 2>&1`) {
                if ($inc_line =~ /End of search list\./) {
                    $is_system_inc = 0;
                } elsif ($is_system_inc) {
                    # Remove leading/trailing whitespace
                    $inc_line =~ s/^[ \t]+//;
                    $inc_line =~ s/[ \t]+$//;

                    push @flags, "-isystem$inc_line";
                } elsif ($inc_line =~ /#include <...> search starts here:/) {
                    $is_system_inc = 1;
                }
            }
        }
    }

    chomp @flags;

    return @flags;
}

sub command_is_cpp {
    my $command = $_[0];

    my $is_cpp = ($command->{"file"} =~ /\.(cpp|cc|cxx|c\+\+)$/);
    my $found_x = 0;

    for my $arg (@{$command->{"arguments"}}) {
        $arg =~ s/^\s+//;
        $arg =~ s/\s+$//;

        if ($arg eq "-x") {
            $found_x = 1;
        } elsif ($found_x) {
            $is_cpp = ($arg =~ /[Cc]\+\+/);
            $found_x = 0;
        }
    }

    return $is_cpp;
}

sub command_stdinc {
    my $command = $_[0];
    my $stdinc = 1;
    my $stdinc_cpp = command_is_cpp($command);

    for my $arg (@{$command->{"arguments"}}) {
        $arg =~ s/^\s+//;
        $arg =~ s/\s+$//;

        if ($arg eq "-nostdinc") {
            $stdinc = 0;
        } elsif ($arg eq "-nostdinc++") {
            $stdinc_cpp = 0;
        }
    }

    return ($stdinc, $stdinc_cpp);

}

sub readcdb {
    my $filename = "compile_commands.json";

    if(@_ > 0) {
        ($filename) = @_;
    }

    my $cdbstr = do {
        open(my $cdb, "<", $filename) or
        die "$filename does not exist!";

        local $/ = undef;
        <$cdb>;
    };

    decode_json($cdbstr) or die "Failed to code JSON";
}

sub writecdb {
    my ($cdbref) = @_;

    my $json_str = to_json($cdbref, {utf8 => 1, pretty => 1});

    print STDOUT $json_str;
}
