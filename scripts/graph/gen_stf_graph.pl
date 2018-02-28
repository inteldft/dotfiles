#!/usr/intel/pkgs/perl/5.14.1/bin/perl

use strict;
use warnings;
use autodie qw{close};
use English qw{ -no_match_vars }; # avoid regex penalties

BEGIN {
    die "Error: Please source SPF environment!\n\n" unless exists $ENV{SPF_PERL_LIB};
}

use lib $ENV{SPF_PERL_LIB};

my @data = ();
my @property_names = qw( name stf_agt_type stf_parent stf_order );

my $stf_spf_spec_file;
my $text_files = 0;
my ($arg1, $arg2) = @ARGV;

if (defined $arg1) {
    if ($arg1 eq '--text_files') {
        $stf_spf_spec_file = $arg2;
        $text_files = 1;
    } else {
        $stf_spf_spec_file = $arg1;
    }
}


if (not defined $stf_spf_spec_file) {
    die "Error: No SPF Spec given\n";
}

# Open STF SPFSpec
use SPF::STF::Spec;
my $stf_spec = SPF::STF::Spec->new ($stf_spf_spec_file);

my @controllers = $stf_spec->get_each_controller;
my $controller = $controllers[0]; # Only ONE controller allowed
explore($controller);

sub explore {
    my ($parent) = @_;        # Passing parent because I want access to its name
    my @ring = $parent->get_each_ring_stop;
    while (my ($order, $ring_stop) = each (@ring)) {

        my $properties = {};

        $properties->{name}       = $ring_stop->get_name;
        $properties->{stf_parent} = $parent->get_name;
        $properties->{stf_order}  = $order;

        if ($ring_stop->is_a_hub()) {
            explore($ring_stop);
            $properties->{stf_agt_type} = 'HUB';
        } else {
            $properties->{stf_agt_type} = 'SSS';
        }
        push @data, $properties;
    }
    return;
}

# Build up topology parent child relationships
my %topology = ();
foreach my $record ( @data ) {
    $topology{ $record->{stf_parent} }[ $record->{stf_order} ] = $record->{name};
}

# Generate the Graphviz dot file
open my $fh, '>', 'stf.dot' or die "Unable to create stf.dot\n";
print {$fh} "digraph stf_network {\n";

my $controller_name = $controller->get_name();
print {$fh} "node [shape=rectangle fillcolor=blue style=filled]; $controller_name\n";
print {$fh} 'node [shape=ellipse fillcolor=yellow style=filled];';
foreach my $record ( @data ) {
    if ( $record->{stf_agt_type} eq 'HUB' ) {
        print {$fh} "  $record->{name}";
    }
}
print {$fh} "\n";

print {$fh} "node [shape=ellipse fillcolor=white style=filled];\n"
    . "\n";

foreach my $ring_stop ( sort keys %topology ) {
    my @children = grep { defined } @{$topology{$ring_stop}};

    printf {$fh} "%-35s -> %-35s;\n", $ring_stop, $children[0];

    if ( $#children > 0 ) {

        for my $i (1..$#children) {
            printf {$fh} "%-35s -> %-35s;\n", $children[$i-1], $children[$i];
        }
        printf {$fh} "%-35s -> %-35s;\n", $children[-1], $ring_stop;
    } else {
        printf {$fh} "%-35s -> %-35s;\n", $children[0], $ring_stop;
    }
    print {$fh} "\n";
}

print {$fh} "}\n";

close $fh;

if ($text_files) {
    # Write source data to a csv file for easy inspection
    open $fh, '>', 'stf.csv' or die "Unable to create 'stf.csv'\n";
    print {$fh} join (q{,}, @property_names ) . "\n";

    foreach my $record ( @data ) {
        my @line = ();
        foreach my $column_name ( @property_names ) {
            if (exists $record->{$column_name}) {
                push @line, $record->{$column_name};
            }
        }
        local $LIST_SEPARATOR = q{,};
        print {$fh} "@line\n";
    }

    close $fh;
}

system('/usr/intel/pkgs/graphviz/2.26.3/bin/dot -Tpng stf.dot -o stf.png'); # Generate an image from the Graphviz file

if (not $text_files) {
    unlink 'stf.dot';
}

exit;

__END__


### =======================================================================

=head1 NAME

gen_stf_graph.pl - create graph of STF network

=head1 SYNOPSIS

    gen_stf_graph.pl [--text_files]  : create DOT and CSV files
                     <STF spec file> : SPF spec to analyze

=head1 DESCRIPTION

Creates a graph of the stf network based on the SPF spec in the form of
PNG image. Giving the options --text_files will cause other generated
colateral including a CSV version of the network and the dot file itself.

=head1 AUTHORS

Troy Hinckley troy.j.hinckley@intel.com SDG

=head1 COPYRIGHT AND LICENCE

(c) Copyright 2017, Intel Corporation, all rights reserved.

=cut

### =======================================================================
