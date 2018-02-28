#!/usr/intel/pkgs/perl/5.14.1/bin/perl

use warnings;
use strict;

use feature 'say';

use lib $ENV{SPF_PERL_LIB};

use SPF::Spec;
my $spec = SPF::Spec->new ($ENV{TAP_SPFSPEC});

foreach my $tap ($spec->get_each_tap()) {

    my ($scandump_reg) = grep { $_->get_name =~ /scandatachain/i } $tap->get_each_register();
    next if not defined $scandump_reg;
    my $scandump_tdi_deadbits = 0;
    my $scandump_tdo_deadbits = 0;
    my @aliases = SPF::Alias::sort ($scandump_reg->get_each_alias);
    foreach (@aliases) {
        if ($_->get_name =~ /tdo_deadbit/i ) {
            $scandump_tdo_deadbits += $_->get_size;
        } else {
            last;
        }
    }

    say $tap->get_name() unless $scandump_tdo_deadbits;
}
