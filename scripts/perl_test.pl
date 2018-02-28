#!/usr/intel/pkgs/perl/5.14.1/bin/perl
use feature 'say';
use Data::Dumper;

use warnings;
use strict;


my %hash = (
    home => $ENV{HOME},
);

use Getopt::Long;

my $var = $ENV{''};

if ($var) {
    say 'work';
} else {
    say 'not';
}
