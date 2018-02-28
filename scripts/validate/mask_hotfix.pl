#!/usr/intel/pkgs/perl/5.14.1/bin/perl

use warnings;
use strict;

use feature 'say';

use lib "$ENV{XWEAVE_REPO_ROOT}/lib/perl5";
require XWeave::DesignInspector;

my $xweave = $ENV{XWEAVE};

my $design = XWeave::DesignInspector->new(json => $xweave);

foreach my $sss ($design->get_each_scan_agent) {

    my $scan_ip_version = 'unknown'; # Reset to default
    my $mask_hotfix = undef;

    if ($sss->can('has_ip_version') and $sss->has_ip_version) {
        $scan_ip_version = $sss->get_ip_version;
    }
    if ($sss->can('has_mask_chains_hotfix')) {
        $mask_hotfix = $sss->has_mask_chains_hotfix;
    }

    # support for old version based solutions.
    unless (defined $mask_hotfix) {
        $mask_hotfix = ($scan_ip_version =~ /(0p9|1p0)/);
    }


    if ($sss->get_name() =~ /rlink/i) {
        say $sss->get_name();
        say "hotfix 1 = $mask_hotfix";

        if ($sss->can('has_ip_version') and $sss->has_ip_version) {
            say "version =" . $sss->get_ip_version;
        }
        if ($sss->can('has_mask_chains_hotfix')) {
            my $var = $sss->has_mask_chains_hotfix;
            say "hotfix = $var";
        }
    }

    say $sss->get_name() unless $mask_hotfix;
}
