#!/usr/intel/pkgs/perl/5.20.1/bin/perl
use strict;
use warnings;
use XML::LibXML;

my @data = ();
my @property_names = (
    'name',
    'StfAgtType',
    'StfParent',
    'StfOrder',
);

my ($topology_file) = @ARGV;

if ( not defined $topology_file) {
    die "Error: No topology file given\n";
} elsif ($topology_file eq "-h" or $topology_file eq "--help") {
    die "Usage: gen_dot.pl <TOPOLOGY_FILE_NAME>.xml\n\nOutput is created in CWD\n\nOutput files:\n  -stf.dot\n  -stf.csv\n  -stf.png\n";
}

# Load the data from the stf_top_crif.xml file
my $dom = XML::LibXML->load_xml( location => $topology_file );
# my $dom = XML::LibXML->load_xml( location => "stf_top_crif.xml" );

foreach my $node ( $dom->findnodes( "/crif/registerFile" ) ) {
    my $properties = {};

    foreach my $name ( @property_names ) {
        $properties->{$name} = $node->findvalue( $name );
    }

    $properties->{name} =~ s{^[^\/]+\/}{}xms;
    push @data, $properties;
}

# Build up topology parent child relationships
my %topology = ();
foreach my $record ( @data ) {
    $topology{ $record->{StfParent} }[ $record->{StfOrder} ] = $record->{name};
}

# Generate the Graphviz dot file
open my $fh, '>', 'stf.dot' or die "Unable to create stf.dot\n";
print {$fh} "digraph stf_network {\n";

print {$fh} "node [shape = ellipse fillcolor=yellow style=filled];";
foreach my $record ( @data ) {
    if ( $record->{StfAgtType} eq "HUB" ) {
        print {$fh} "  $record->{name}";
    }
}
print {$fh} "\n";

print {$fh} "node [ shape= ellipse fillcolor=white style=filled];\n"
    . "\n";

foreach my $node ( sort keys %topology ) {
    my @children = grep defined, @{$topology{$node}};

    printf {$fh} "%-35s -> %-35s;\n", $node, $children[0];

    if ( $#children > 0 ) {

        for ( my $i = 1; $i <= $#children; $i++ ) {
            printf {$fh} "%-35s -> %-35s;\n", $children[$i-1], $children[$i];
        }
        printf {$fh} "%-35s -> %-35s;\n", $children[$#children], $node;
    } else {
        printf {$fh} "%-35s -> %-35s;\n", $children[0], $node;
    }
    print {$fh} "\n";
}

print {$fh} "}\n";

close $fh;

# Write source data to a csv file for easy inspection
open $fh, '>', 'stf.csv' or die "Unable to create 'stf.csv'\n";
print {$fh} join (',', @property_names ) . "\n";

foreach my $record ( @data ) {
    my @line = ();
    foreach my $column_name ( @property_names ) {
        if ( exists $record->{$column_name} ) {
            push @line, $record->{$column_name};
        }
    }
    local $" = ',';
    print {$fh} "@line\n";
}

close $fh;

system("/usr/intel/pkgs/graphviz/2.26.3/bin/dot -Tpng stf.dot -o stf.png"); # Generate an image from the Graphviz file

exit;
