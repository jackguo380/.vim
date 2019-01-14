#! /usr/bin/perl

use strict;
use warnings;
use JSON;
use Getopt::Long;
use Term::ANSIColor;

my $COMMANDS = "
help    - get help for a specific command
addflag - add a compile flag to the database
rmflag  - remove a compile flag from the database
lsflag  - lookup flags matching a regex
abspath - make flags with paths absolute
join    - join multiple compile databases together
";

if(not @ARGV) {
    usage();
    exit 1;
} elsif($ARGV[0] eq "help") {
    helpcommand();
} elsif($ARGV[0] eq "addflag") {
    addflagcommand();
} elsif($ARGV[0] eq "rmflag") {
    rmflagcommand();
} elsif($ARGV[0] eq "lsflag") {
    lsflagcommand();
} elsif($ARGV[0] eq "abspath") {
    abspathcommand();
} elsif($ARGV[0] eq "join") {
    joincommand();
} else {
    print STDERR colored("Unknown command: $ARGV[0]\n", "red")
    unless($ARGV[0] eq "-h" or $ARGV[0] eq "--help");

    usage();
    exit 1
}

exit 0;

sub usage {
    print STDERR "
Clang compilation database manipulation tool

Can be used to modify a compile_commands.json database

Usage:
compiledbtool.pl <command> [<args to command..>]

Commands:
$COMMANDS
"
}

sub helpcommand {
    if(@ARGV < 2) {
        print STDERR "
Usage:
compiledbtool.pl help <command>

Commands:
$COMMANDS
"
    } elsif($ARGV[1] eq "addflag") {
        print STDERR "
Add the flag to all files in the database.

Usage:
compiledbtool.pl addflag [<options>] <flag>

Options:
None so far...
"

    } elsif($ARGV[1] eq "rmflag") {
        print STDERR "
Remove all flags matching <regex>

Usage:
compiledbtool.pl rmflag [<options>] <regex>

Options:
None so far...
"

    } elsif($ARGV[1] eq "lsflag") {
        print STDERR "
List all flags matching <regex>

Usage:
compiledbtool.pl lsflag [<options>] <regex>

Options:
--before N  - Number of arguments to display before matched argument
--after N   - Number of arguments to display after matched argument
"

    } elsif($ARGV[1] eq "abspath") { 
        print STDERR "
Change relative paths to absolute paths.
if --working-directory is given don't modify flags but just
add -working-directory for all files.

Usage:
compiledbtool.pl abspath [<options>]

Options:
--working-directory - use Clang's -working-directory flag
"
    } elsif($ARGV[1] eq "join") { 
        print STDERR "
Join multiple compile_commands.json together
The last filename is the output.

Usage:
compiledbtool.pl join [<options>] <cdb1> <cdb2> [<cdb3> ...] <cdbout>

Options:
None so far...
"
    }
}

sub addflagcommand {
    die "A flag is required" if (@ARGV < 2);

    my $flag = $ARGV[1];
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
    die "A regex is required" if (@ARGV < 2);

    my $regex = qr/($ARGV[1])/;
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
    die "A regex is required" if (@ARGV < 2);

    my $regex = qr/$ARGV[1]/;

    shift @ARGV;
    shift @ARGV;

    # TODO: implement this
    my $nbefore = '0';
    my $nafter = '0';

    GetOptions(
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
                print STDERR colored($curfile, "yellow"), ": $arg\n";
            }
        }
    }
}

sub abspathcommand {
    my $useworkdir = 0;

    GetOptions(
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
            die "Not implemented yet";
            my $next_is_path = 0;

            for my $idx (0 .. @{$command->{"arguments"}} - 1) {
                my $arg = $command->{"arguments"}[$idx];
                my $path;
                if($arg =~ /^-I(.+)/) {
                } elsif($arg =~ /^-isystem(.+)/) {
                    print STDERR colored($curfile, "yellow"), ": $arg\n";
                }
            }
        }
    }

    writecdb($cdb);
}

sub joincommand {
    shift @ARGV;
    
    if(@ARGV < 2) {
        die "Specify atleast 2 files";
    }

    my @joinedcdb;

    for my $cdbfile (@ARGV[0..-2]) {
        push @joinedcdb, @{readcdb($cdbfile)};
    }

    if(-f $ARGV[-1]) {
        push @joinedcdb, @{readcdb($ARGV[-1])};
    }

    writecdb(\@joinedcdb);
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
