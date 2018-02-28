#!/usr/intel/pkgs/perl/5.20.1/bin/perl
use strict;
use warnings;
use List::Util qw(min);
use List::Util qw(max);
use File::Basename;
use Data::Dumper;

my ($in_file) = @ARGV;

my %topology;

open (my $fh, $in_file)
    or die "could not open file $in_file $!";

my $row = <$fh>;
chomp $row;

my @hubs = ();
while ($row = <$fh>) {
    chomp $row;
    my @record = split (/,/, $row);
    if (scalar @record == 4) {
        $topology{$record[2]}{$record[3]} = $record[0];
        if ($record[1] eq "HUB") {
            push @hubs, $record[0];
        }
    }
}
close $fh;

(my $name = basename($in_file)) =~ s/\.[^.]+$//;

open $fh, '>', "${name}.dot" or die "Unable to create '${name}.dot'\n";

print {$fh} "digraph stf_network {\n" . "node [shape = ellipse fillcolor=yellow style=filled];  ";
print {$fh} join('  ', @hubs);
print {$fh} "\nnode [ shape= ellipse fillcolor=white style=filled];\n\n";

while (my ($parent, $ring_ref) = each %topology) {
    my %ring = %{$ring_ref};
    while (my ($order, $name) = each %ring) {
        if (exists $ring{$order + 1}) {
            print {$fh} $name . " -> " . $ring{$order + 1} . " ;\n";
        }
    }
    my $min = min keys %ring;
    my $max = max keys %ring;
    print {$fh} $ring{$max} . " -> " . $parent . " ;\n";
    print {$fh} $parent . " -> " . $ring{$min} . " ;\n";
    print {$fh} "\n";
}
print {$fh} "}\n";
