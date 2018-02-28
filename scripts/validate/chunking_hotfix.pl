#!/usr/intel/pkgs/perl/5.14.1/bin/perl

use warnings;
use strict;

use feature 'say';

use lib "$ENV{XWEAVE_REPO_ROOT}/lib/perl5";
require XWeave::DesignInspector;

my $xweave = $ENV{XWEAVE};

my $design = XWeave::DesignInspector->new(json => $xweave);

foreach my $sss ($design->get_each_scan_agent) {

    my $chunking_hotfix = undef;


    $chunking_hotfix = ($sss->can('has_chunking_hotfix') and $sss->has_chunking_hotfix) // 0;


    say $sss->get_name() unless $chunking_hotfix;
}
