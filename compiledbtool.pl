#! /usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptionsFromArray);
use Term::ANSIColor;
use File::Spec::Functions qw(canonpath file_name_is_absolute);

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
    #    'globalflags' => \&globalflagscommand
);

my $COMMANDS = "
help    - get help for a specific command
addflag - add a compile flag to the database
rmflag  - remove a compile flag from the database
lsflag  - lookup flags matching a regex
abspath - make flags with paths absolute
join    - join multiple compile databases together
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
            print STDERR "Missing arguments key for $curfile\n";
            die "Cannot support older command schema";
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
            print STDERR "Missing arguments key for $curfile\n";
            die "Cannot support older command schema";
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
            print STDERR "Missing arguments key for $curfile\n";
            die "Cannot support older command schema";
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
            print STDERR "Missing arguments key for $curfile\n";
            die "Cannot support older command schema";
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
            print STDERR "Missing arguments key\n";
            die "Cannot support older command schema";
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
