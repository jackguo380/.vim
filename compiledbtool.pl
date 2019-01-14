#! /usr/bin/perl

use strict;
use warnings;
use JSON;
use Getopt::Long;
use Term::ANSIColor;

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
} else {
    print STDERR colored("Unknown command: $ARGV[0]\n", "red")
    unless($ARGV[0] eq "-h" or $ARGV[0] eq "--help");

    usage();
    exit 1
}

sub usage {
    print STDERR "
Clang compilation database manipulation tool

Can be used to modify a compile_commands.json database

Usage:
compiledbtool.pl <command> [<args to command..>]

Commands:
help    - get help for a specific command
addflag - add a compile flag to the database
rmflag  - remove a compile flag from the database
lsflag  - lookup flags matching a regex
abspath - make flags with paths absolute
"
}

sub helpcommand {
    if(@ARGV < 2) {
        print STDERR "
Usage:
compiledbtool.pl help <command>

Commands:
help    - get help for a specific command
addflag - add a compile flag to the database
rmflag  - remove a compile flag from the database
lsflag  - lookup flags matching a regex
abspath - make flags with paths absolute
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
Not implemented
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

        for my $idx (@remlist) {
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
    print STDERR "Not yet implemented";
}

sub readcdb {
    my $cdbstr = do {
        open(my $cdb, "<", "compile_commands.json") or
        die "compile_commands.json does not exist!";

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
