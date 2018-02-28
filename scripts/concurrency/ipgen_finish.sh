#!/usr/intel/bin/bash
. "/nfs/site/home/tjhinckl/scripts/concurrency_control.sh"
set -e

subsystem=${PWD##*/}
model_root=$1
model=${model_root##*/}
dft_repo=$2

if [ ! -d "$dft_repo" ]; then
    echo "ERROR: DFT_REPO_ROOT not set" 1>&2
    exit 1
fi

if [ "$model" = "mem_tot_ww44" ]; then
    if [ "$subsystem" = "mchbm" ] || [ "$subsystem" = "mcddr_mee" ]; then
        echo "waiting for power domain to be available"
        wait_for_mutex mcchan_power_domain
        if [ "$subsystem" = "mchbm" ]; then
            /nfs/site/home/tjhinckl/scripts/mcchan_power_domain.pl $model_root vnmc
        elif [ "$subsystem" = "mcddr_mee" ]; then
            /nfs/site/home/tjhinckl/scripts/mcchan_power_domain.pl $model_root vdrd
        fi
    fi
fi

set -x

if [ ! -d "$HOME/temp/resources/pid/$model" ]; then
    mkdir "$HOME/temp/resources/pid/$model"
fi
~/scripts/wait_for_ipgen_failure.sh &
echo $! > "$HOME/temp/resources/pid/$model/$subsystem"

$dft_repo/DFTNetworkGen/run_dft_ipgen process_json
$dft_repo/DFTNetworkGen/run_dft_ipgen xweave

if [ "$model" = "mem_lcp_ww46" ]; then
    ~/scripts/mem_hack_script.pl -rtlpath_file output/xweave/rtlpaths/rtlpaths.pl -substitute_file "$HOME/temp/${subsystem}_macros.txt"
    ~/scripts/mem_hack_script.pl -rtlpath_file output/xweave/design_report.json -substitute_file "$HOME/temp/${subsystem}_macros.txt"
fi

$dft_repo/DFTNetworkGen/run_dft_ipgen gen_stf
$dft_repo/DFTNetworkGen/run_dft_ipgen gen_tap

if [ "$subsystem" = "mcchan" ]; then
    perl -pi -e 's/E  mcchan_sss\s+sss_fstf_pid_strap/E  mcchan_sss\/sss_fstf_pid_strap/' output/xweave/adhoc_connection.txt
fi

$dft_repo/DFTNetworkGen/run_dft_ipgen gen_dft

pkill -P $$ # kill the listener process

if [ "$model" = "mem_tot_ww44" ]; then
    release_mutex mcchan_power_domain
fi

"$model_root/scripts/fixup_ipgen.pl" -dut "$subsystem"

if [ "$model" = "mem_lcp_ww46" ] && [ "$subsystem" = "scf_mem" ]; then
    cp output/dft/verif/rtl/spf/scf_mem.tap.spfspec output/dft/verif/rtl/spf/scf_mem1.tap.spfspec
    cp output/dft/verif/rtl/spf/scf_mem.tap.spfspec output/dft/verif/rtl/spf/scf_mem2.tap.spfspec
    cp output/xweave/design_report.json output/xweave/design_report1.json
    cp output/xweave/design_report.json output/xweave/design_report2.json

    ~/scripts/mem_hack_script.pl -rtlpath_file output/dft/verif/rtl/spf/scf_mem.tap.spfspec  -substitute_file "$HOME/temp/scf0_macros.txt"
    ~/scripts/mem_hack_script.pl -rtlpath_file output/xweave/design_report.json              -substitute_file "$HOME/temp/scf0_macros.txt"

    ~/scripts/mem_hack_script.pl -rtlpath_file output/dft/verif/rtl/spf/scf_mem1.tap.spfspec -substitute_file "$HOME/temp/scf1_macros.txt"
    ~/scripts/mem_hack_script.pl -rtlpath_file output/xweave/design_report1.json             -substitute_file "$HOME/temp/scf1_macros.txt"

    ~/scripts/mem_hack_script.pl -rtlpath_file output/dft/verif/rtl/spf/scf_mem2.tap.spfspec -substitute_file "$HOME/temp/scf2_macros.txt"
    ~/scripts/mem_hack_script.pl -rtlpath_file output/xweave/design_report2.json             -substitute_file "$HOME/temp/scf2_macros.txt"
fi

if [ "$subsystem" = "mcddr_mee" ]; then
    git checkout -- output/dft/verif/rtl/spf/mcddr_mee.tap2stf.map
fi

if [ "$subsystem" = "mcchan" ]; then
    git checkout -- output/dft/tools/collage/subsystem/dft/permanent_tieoff.txt
fi

set +e
if [ -d collage_work ]; then
    rm -rf collage_work
fi

echo "IPGEN FINISHED"
