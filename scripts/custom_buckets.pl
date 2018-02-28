## the format of this is very particular. The more important errors should be
## first in the array, as the array is evaluated from element 0 down to the
## end.
##
## Each element is a reference to a hash with 2 keys, regexp and bucket.
## regexp is a regular expression that is compared against the failure cause
## given by wmtrun (and stored in the .rpt file). bucket is the name given
## to the bucket. If a grouping occurs in the regular expression, this can be
## referenced in teh bucket string. It is VERY important that the bucket
## string contains the error within two sets of quotes ('"bucket"'), as this
## string is eval'ed, and the enclosing double quotes will tell perl to
## evaluate as a string instead of as an executable statement.

use strict;
use warnings;

our @failure_regexps = (
    {
        regexp => 'SpecmanOpts: CTE binary does not exist:.+/([^/]+$)',
        bucket => 'model: Missing CTE binary: $1',
    },

    {
        regexp => 'SpecmanOpts: compiled cte binary .+ is stale',
        bucket => 'model: Stale CTE binary',
    },

    # {
    #     regexp => 'Comparator Error',
    #     bucket => \&bin_chekhov,
    # },

    # {
    #     regexp => 'Chekhov Error',
    #     bucket => \&bin_chekhov,
    # },

    {
        regexp => '0in:\s+Message:\s+(.+)',
        bucket => '0in: $1',
    },

    {
        regexp => '0-IN: Message: (.+)',
        bucket => '0in: $1',
    },

    {
        regexp => '0In ERROR Firing: .*\.(\w+)\.(\w+) ',
        bucket => '0in: $1.$2',
    },

    {
        regexp => 'POST PROCESSING FAILURE: TOOL: proto',
        bucket => \&bin_proto,
    },

    {
        regexp => '(NO HALT ENCOUNTERED)',
        bucket => '$1',
    },

    # Migi cycle limit:
    {
        regexp => 'Test id \w+ exceeded cycle limit',
        bucket => 'NO HALT ENCOUNTERED',
    },

    {
        regexp => 'SPECMAN: (.+)',
        bucket => 'specman: $1',
    },

    {
        regexp => 'specman: (.+)',
        bucket => 'specman: $1',
    },

    {
        regexp => '(Dut error)',
        bucket => 'specman: $1',
    },

    {
        regexp => 'Error: Contradiction',
        bucket => 'Contradiction Error',
    },

    {
        regexp => '(UNKNOWN CSIM EXIT STATUS OCCURRED)',
        bucket => '$1',
    },

    ## wmtrun_errs.pl treats any string with 'error' in it as a fatal
    ## error. However sometimes there are legitimate reasons to have
    ## error in a string, so these cases need to be manually ignored.
    {
        regexp => 'uop_trace.+(EOM detected .+)',
        bucket => '[$1]: Likely a wmtrun_errs.pl problem; see Sam.',
    },

    {
        regexp => '1\) (.+) \@',
        bucket => '$1',
    },

    #--------------------------------------------------------------------------------
    # A few special cases
    #--------------------------------------------------------------------------------
    {
        regexp => '!!Checker (\w+) #1 - Offending IP',
        bucket => '!!Checker $1 #1 - Offending IP',
    },

    {
        regexp => 'RESTRICTION:\s+#(\d+):\s+LIP\s+\w+,\s+UIP\s+\w+:\s+(.*)',
        bucket => 'RESTRICTION: $1: $2',
    },

    {
        regexp => '(CATCH Error: Unmatched:.*)',
        bucket => '$1',
    },

    #------------------------------------------------------
    #1 csim\s+FATAL\s+ERROR
    #------------------------------------------------------
    {
        regexp => 'csim\s+FATAL\s+ERROR',
        bucket => 'csim FATAL ERROR',
    },

    {
        regexp => 'POST PROCESSING FAILURE: TOOL: (.+)',
        bucket => 'post processing failure: $1',
    },

    {
        regexp => 'TEST COMPLETED',
        bucket => 'TEST COMPLETED (usually pass)',
    },

    {
        regexp => '(No TEST RESULTS defined)',
        bucket => '$1 (Test hang?)'
    },
    #------------------------------------------------------
    #OVM errors
    #------------------------------------------------------
    {
        regexp => '^OVM_ERROR .+Driver \[ovm_driver',
        bucket => 'OVM_ERROR: JTAG BFM mismatch'
    },
    {
        regexp => 'Driver check expected packet Failed',
        bucket => 'Driver Check: expected packet mismatch'
    },
    {
        regexp => '^OVM_ERROR .+?: [^ ]+ (\[SPF_ITPP_PARSER_ERROR\]) signal',
        bucket => 'OVM_ERROR: $1 signal path does not exist'
    },
    {
        regexp => '^OVM_ERROR .+?: [^ ]+ (\[[[:alnum:]_]+?\][^;.]+?\[.+?\])',
        bucket => 'OVM_ERROR: $1'
    },
    {
        regexp => '^OVM_ERROR .+?: [^ ]+ (\[.+?\][^.;=]+)',
        bucket => 'OVM_ERROR: $1'
    },
    {
        regexp => ', \d+: .+?([^.]+?): ',
        bucket => 'Assertion: $1'
    },
    {
        regexp => '^OVM_FATAL .* (\[.+?\] [^\']+)',
        bucket => 'OVM_FATAL: $1'
    },
    {
        regexp => 'segmentation fault',
        bucket => \&bin_seg_fault,
    },

    # Fallback, if nothing else matches. KEEP THIS LAST.
    {
        regexp => '(.*)',
        bucket => '$1',
    },
);


sub bin_seg_fault {
    my $test_ref = shift;
    my $result_dir = $test_ref->{'RESULTS DIR'};

  BUCKET: {
        last unless $result_dir;
        last unless -d $result_dir;
        my ($file_name) = glob "$result_dir/postsim.log*";
        last unless -e $file_name;
        my $fh = do {
            if ($file_name =~ /\.gz$/) {
                require IO::Uncompress::Gunzip;
                new IO::Uncompress::Gunzip $file_name;
            } else {
                open my $handle, '<', $file_name;
                $handle;
            }
        };
        last unless fileno $fh;

        while (my $row = <$fh>) {
            if ($row =~ /\[Error Summary\]/i) {
                <$fh>;
                <$fh>;
                my $error = <$fh>;
                last unless ($error =~ s/^ +//);

                foreach my $e (@failure_regexps) {
                    if ($error =~ /$e->{regexp}/i) {
                        last if (ref $e->{bucket} eq 'CODE');
                        # return $e->{bucket};
                        return eval "\"$e->{bucket}\"";
                    }
                }
                last;
            }
        }

    }

    return 'Segmentation fault';

}

our @avdebug_regexp_hooks = (
    sub {                       # Strip CSI correlation specifics
        $_[0] = "" if (!defined($_[0]));
        $_[0] =~ s/(csipacket|llc_req|any_ifc)_s-\@\d+ with bsqid 0x[A-Fa-f0-9]+, csid 0x[A-Fa-f0-9]+, and uncid 0x[A-Fa-f0-9]+/$1_s-\@\* with bsqid 0x\*, csid 0x\*, and uncid 0x\*/;
        $_[0] =~ s/((?:core|gq)_list_entry_s-@)\d+/$1*/;
        $_[0] =~ s/: address 0x[0-9a-f]+/: address xxxx/;
        $_[0] =~ s/sad_rule_s-@\d+/sad_rule_s X/;
    },
);

sub bin_chekhov {

    my $test_ref = shift;
    my $result_dir = $test_ref->{'RESULTS DIR'};
    unless ($result_dir && -d $result_dir && open(LOG, "$result_dir/chekhov_log.out")) {
        return "Checker Mismatch";
    }

    my %mismatched_regs;

    # Matching against:
    #
    # !! ----Diagnostics Info------
    # !!    ArchSim Inst. Info.
    # !! Agent(0)   Global Inst Seq(20)   Agent Inst Seq(20)
    # !! IP(0x000000004E00E81F)   Retire Time(113786)
    # !! REGISTER:fst6  RTL Value: 3FFDEC00000000000000  SIM Value: 4001C000000000000000
    # !! REGISTER:fst6  RTL Value: 3FFDEC00000000000000  SIM Value: 4001C000000000000000

    my ($return_str, $addr);
    while (my $line = <LOG>) {
        if ($line =~ /Chekhov error:/) {
            my $type_of_mismatch = <LOG>;
            if ($type_of_mismatch !~ /\[Comparator\]/) {
                ($return_str = $type_of_mismatch) =~ s/^!![^\]]+\]/Chekhov:/;
                chomp $return_str;
                $return_str =~ s/ADDR:[0-9A-F]+/ADDR:xxxx/;
                return $return_str;
            }
            next;
        } elsif ($line =~ m/IP\((?:0x)?([A-F0-9]+)\)/) {
            $addr = $1;
        } elsif ($line =~ m/!!\s*REGISTER:(\w+)/) {
            $mismatched_regs{uc($1)} = 1;
        } elsif ($line =~ m/!!\s*ADDR/) {
            $mismatched_regs{'ADDR/MEM'} = 1;
        }
    }

    my @lstfiles;
    if (exists $test_ref->{'BUILD DIR'}) {
        @lstfiles = glob("$result_dir/" . $test_ref->{'BUILD DIR'} . "/*.lst*");
    } elsif ($result_dir =~ m{/job[\.\d]+$}) {
        @lstfiles = glob("$result_dir/". $test_ref->{'TEST NAME'} . "*/*.lst*");
    } else {
        @lstfiles = glob("$result_dir/*.lst*");
    }
    my ($lstfile) = grep /\.lst(\.gz)?$/, @lstfiles;
    if (defined($addr) && defined($lstfile) && -r $lstfile) {
        my $instr = `zgrep -i $addr $lstfile`;
        (undef, undef, $instr) = split(' ',$instr);
        $return_str = "Checker Mismatch after ". uc($instr). ": ";
    } else {
        $return_str = "Checker mismatch: ";
    }

    my @mismatched = sort keys %mismatched_regs;


    my %mismatched_type = ();
    foreach my $reg (@mismatched) {
        if ($reg =~ /^R[A-D]X$/) {
            if (!exists($mismatched_type{'GPR'})) {
                $return_str .= "GPR* ";
                $mismatched_type{'GPR'} = 1;
            }
        } elsif ($reg =~ /^MM[0..7]$/) {
            if (!exists($mismatched_type{'MM'})) {
                $return_str .= "MM* ";
                $mismatched_type{'MM'} = 1;
            }
        } elsif ($reg =~ /^XMM([0-9]|1[0-5])$/) {
            if (!exists($mismatched_type{'XMM'})) {
                $return_str .= "XMM* ";
                $mismatched_type{'XMM'} = 1;
            }
        } elsif ($reg =~ /^FST[0-7]$/) {
            if (!exists($mismatched_type{'FP'})) {
                $return_str .= "FP* ";
                $mismatched_type{'FP'} = 1;
            }
        } else {
            $return_str .= "$reg ";
        }
    }

    return $return_str;
}

sub bin_proto {
    my $test_ref = shift;
    my $result_dir = $test_ref->{'RESULTS DIR'};
    my $proto_status = "$result_dir/PROTO_run_dir/PROTO.status";
    my $msg;
    if (-f $proto_status) {
        $msg = `/usr/bin/tail -1 $proto_status`;
    } elsif (-f "$proto_status.gz") {
        $msg = `/usr/bin/gunzip -c $proto_status.gz | /usr/bin/tail -1`;
    }
    if (!defined $msg || $msg !~ /^PROTO/) {
        $msg = "Unexpected PROTO error - see the test log file for more info";
    }
    return $msg;
}

1;
