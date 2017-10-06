#!/usr/intel/pkgs/perl/5.14.1/bin/perl

use strict;
use warnings;

my ($file) = @ARGV;

open my $fh, '<', $file or exit 0;

my $lines = q();
my $paren_depth = 0;
while (<$fh>) {
    next unless /^\s*GetOptions\s*[(]/;
    $lines .= $_;
    last if paren_match($_);
    while (<$fh>) {
        $lines .= $_;
        last if paren_match($_);
    }
}

close $fh;

$lines =~ s/#.*$//mg;
if ($lines =~ /GetOptions[\s\n]*[(](.*?)[)]/s) {
    my $match = $1;
    $match =~ s/=>.*(?:,|$)//mg;
    my @matches = $match =~ /(?:^|['"|\s(])([[:alpha:]_][[:alnum:]_]*)\b(?![({};])/mg; # At some point make this regex less ugly
    print join q{ }, map { q{-} . $_ } @matches;
}

sub paren_match {
    my ($line) = @_;
    my $open_paren  = $line =~ tr/[(]//;
    my $close_paren = $line =~ tr/[)]//;

    $paren_depth += $open_paren - $close_paren;
    return $paren_depth == 0;
}
