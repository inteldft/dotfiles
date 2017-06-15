#!/usr/intel/bin/bash

# print out the size of all files/directories in the specified directory and sort them by size
dir-size () {
    du -a -h --max-depth=1 "${1-.}" | sort -h
}

man() {
    /usr/intel/bin/tman "$@" || /usr/bin/man "$@"
}

# source a C-shell script
csrc() {
    eval "$(csh-source --inline "$@")"
}

count() {
    find "${1-.}" -maxdepth 1 -type f | wc -l
}

rename() {
    if [[ -z ${1+x} ]]; then
        echo "USAGE: rename <perl substitution regex>"
        return
    fi
    perl -we "for (glob '*') { (my \$name = \$_) =~ $1; rename(\$_, \$name) if (\$name ne \$_); }"
}

rm-old () {
    if [[ -z ${1+x} ]]; then
        echo "USAGE: rm-old <number of days to keep> <optional directory>"
        return
    fi
    echo "Removing files older than $1 day(s) in ${2-cwd}"
    find "${2-.}" -ctime +"$1" -exec rm -rf {} +
}

mdcd () {
    if [[ -z ${1+x} ]]; then
        echo "must specify a directory"
        return
    fi
    mkdir -p "$1"
    cd "$1" || return
}

# give me a clean path with nothing mixed up
clean-path () {
    export PATH='/usr/intel/pkgs/bash/4.1/bin:' \
'/usr/intel/pkgs/emacs/25.1/bin:' \
'/usr/intel/pkgs/less/418.1-64/bin:' \
'/usr/intel/pkgs/perl/5.14.1-threads/bin:' \
'/nfs/site/home/tjhinckl/.autojump/bin:' \
'/nfs/site/home/tjhinckl/bin:' \
'/usr/intel/bin:' \
'/usr/bin:' \
'/bin:' \
'/usr/bin/X11:' \
'/usr/X11R6/bin:' \
'/opt/kde3/bin:' \
'/usr/lib64/jvm/jre/bin:' \
'/usr/lib/mit/bin:' \
'/usr/lib/mit/sbin:' \
'/usr/lib/qt3/bin:' \
'/usr/sbin:' \
'.'
}

# set up the path that I would have after I sourced the development enviroment
dev-path () {
    clean-path
    if [ "$EC_SITE" == 'sc' ]; then
        pathmunge /p/hdk/rtl/proj_dbin/shdk74
        pathmunge /p/hdk/rtl/bin
        pathmunge /p/hdk/rtl/proj_tools/proj_binx/shdk74/latest
        pathmunge /p/hdk/rtl/valid/bin after
    elif [ "$EC_SITE" == 'fc' ]; then
        pathmunge /p/hdk/rtl/proj_tools/proj_binx/shdk73/latest
        pathmunge /usr/local/bin after
        pathmunge /p/hdk/rtl/proj_dbin/shdk73 after
    fi
    PATH=${PATH//:\.//} #remove cwd from the path and append it to the end (safer)
    # PATH=`echo $PATH | sed -e 's/:\.//'`
    pathmunge . after
    export PATH
}

sync-site () {
    if [[ -z ${1+x} ]]; then
        echo "need to specify a directory"
        return
    fi

    if [ "$EC_SITE" == 'sc' ]; then
        remote_host='fcab1249.fc'
    elif [ "$EC_SITE" == 'fc' ]; then
        remote_host='scci19347.sc'
    else
        echo "remote host unresolved"
        return
    fi

    export REMOTE_HOST=$remote_host
    local cmd="rsync -az $1 ${remote_host}.intel.com:$1"
    eval "$cmd"
}

exith () {
    history | awk -F ' ' '{$1=""; print $0}' >> ~/doc/history.log && exit
}

save_history () {
    history | awk -F ' ' '{$1=""; print $0}' >> ~/doc/history.log
}

# tell me which version of an intel IP I am using
whichip () {
    ToolConfig.pl get_tool_path "$1"
}

# shellcheck disable=SC2120
srcspf () {
    if [[ "$1" == 'latest' ]]; then
        SPF_ROOT=/p/hdk/cad/spf/latest
    else
        SPF_ROOT=$(whichip espf)
    fi

    export SPF_ROOT
    csrc "$SPF_ROOT"/bin/spf_setup_env

    # export SPF_ROOT=/p/hdk/cad/spf/latest
    # cmp --silent "$SPF_ROOT"/bin/spf_setup_env "$HOME"/temp/spf_env/spf_setup_env ||
    #     echo "spf_setup_env has changed. ABORT"
    # spf_setup_env_bash
}

# set the vars required to run ESPF on Chassis
setchassisvars () {
    if [[ -z ${1+x} ]]; then
        echo "Error: Need to provide a version to set chassis variables"
        return
    fi
    export TAP_SPFSPEC=$IP_RELEASES/dft_ipgen_chassis/${1}/tools/ipgen/soc_mini/output/dft/verif/rtl/spf/soc_mini.tap.spfspec
    export TAP2STF_MAP_FILE=$IP_RELEASES/dft_ipgen_chassis/${1}/tools/ipgen/soc_mini/output/dft/verif/rtl/spf/soc_mini.tap2stf.map
    export STF_SPFSPEC=$IP_RELEASES/dft_ipgen_chassis/${1}/tools/ipgen/soc_mini/output/dft/verif/rtl/spf/soc_mini.stf.spfspec
    export XWEAVE=$IP_RELEASES/dft_ipgen_chassis/${1}/tools/ipgen/soc_mini/output/xweave/design_report.json
    export REGLIST_DIR=$MODEL_ROOT/verif/soc_mini/reglist
    export ITPP_DIR=$MODEL_ROOT/verif/soc_mini/spf_itpp_files/stf_itpp
}

# set the vars required to run ESPF on a SS
if [ "$EC_SITE" == 'sc' ]; then
    setdftvars () {
        if [[ -z ${1+x} ]]; then
            echo "Error: Need to provide a model to set dft variables"
            return
        fi

        if [[ -z ${RTL_PROJ_LIB+x} ]]; then
            echo "Error: need to source dev enviroment first (srcenv)"
            return
        fi

        export STF_SPFSPEC=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.stf.spfspec
        export TAP_SPFSPEC=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.tap.spfspec
        export TAP2STF_MAP_FILE=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.tap2stf.map
        export XWEAVE=$MODEL_ROOT/tools/ipgen/${1}/output/xweave/design_report.json
        export REGLIST_DIR=$MODEL_ROOT/verif/reglist/${1}/dft
        export ESPF_DIR=${ESPF_DIR-${HOME}/workspace/chassis_dft_val_global/spf_sequences.1p0/scan}
        export DFT_GLOBAL_DIR=${DFT_GLOBAL_DIR-${HOME}/workspace/chassis_dft_val_global}
        XWEAVE_REPO_ROOT=$(whichip ipconfig/xweave)
        export XWEAVE_REPO_ROOT
        if [[ ! -z ${LD_LIBRARY_PATH+x} ]];  then
            unset LD_LIBRARY_PATH
        fi
        # shellcheck disable=SC2119
        srcspf

    }
else
    setdftvars () {
        if [[ -z ${RTL_PROJ_LIB+x} ]]; then
            echo "Error: need to source dev enviroment first (srcenv)"
            return
        fi


        export STF_SPFSPEC=$MODEL_ROOT/verif/tests/JTAG_BFM_CTT_files/spf/dnv.stf.spfspec
        export TAP_SPFSPEC=$MODEL_ROOT/verif/tests/JTAG_BFM_CTT_files/spf/dnv.tap.spfspec
        export TAP2STF_MAP_FILE=$MODEL_ROOT/verif/tests/dft/source_stfstf/dnv.topo
        export REGLISTDIR=$MODEL_ROOT/verif/tests/lists/regression
        export ESPFDIR=$MODEL_ROOT/verif/tests/dft/source_spf
        export ITPPDIR=$MODEL_ROOT/verif/tests/dft/itpp
        export DFT_GLOBAL_DIR=${DFT_GLOBAL_DIR-${HOME}/workspace/chassis_dft_val_global}

        unset LD_LIBRARY_PATH
        # shellcheck disable=SC2119
        srcspf latest
    }

fi

# interpret Netbatch exit codes
nbexit () {
    nbstatus --tar linux1 constants --fo csv numericvalue=="$1"
}

if [ "$EC_SITE" == 'sc' ]; then
    build-local () {
        if [[ $# -lt 2 ]]; then
            echo "Error: must specify dut and mc to build"
            return
        fi

        if [[ -z ${RTL_PROJ_LIB+x} ]]; then
            echo "Error: need to source dev enviroment first (srcenv)"
            return
        fi

        local stages=""
        if [[ ! -z ${3+x} ]]; then
            stages="-s all +s $3"
        fi

        local postfix=""
        if [[ $3 == sgdft ]] || [[ $3 == sglp ]]; then
            postfix="-1c -dut $1 -1c-";
        fi

        local command="bman -dut $1 -mc $2 $stages $postfix"
        echo "$command"
        eval "$command"
    }

    build () {
        if [[ $# -lt 2 ]]; then
            echo "Error: must specify dut and mc to build"
            return
        fi

        if [[ -z ${RTL_PROJ_LIB+x} ]]; then
            echo "Error: need to source dev enviroment first (srcenv)"
            return
        fi

        local stages=""
        if [[ ! -z ${3+x} ]]; then
            stages="-s all +s $3"
        fi

        local postfix=""
        if [[ $3 == sgdft ]] || [[ $3 == sglp ]]; then
            postfix="-1c -dut $1 -1c-";
        fi

        local command="$GK_CONFIG_DIR/hooks/setup_git_config.pl -c $1; nbjob run --target ${EC_SITE}_critical --qslot $NBQSLOT --mail E bman -dut $1 -mc $2 $stages $postfix"
        echo "$command"
        eval "$command"
    }

    waves () {
        if [[ $# -ne 3 ]]; then
            echo "Error: must specify dut, model, and fsdb file to pull up waves"
            return
        fi

        if [[ -z ${RTL_PROJ_BIN+x} ]]; then
            echo "Error: need to source dev enviroment first (srcenv)"
            return
        fi

        # "$RTL_PROJ_BIN"/rtldebug.bman -dut "$1" -m "$2" -ssf "$3"
        "$HOME"/custom/rtldebug.custom -dut "$1" -m "$2" -ssf "$3" -ver "$MODEL_ROOT"
    }

    reg () {
        if [[ $# -lt 3 ]]; then
            echo "Error: must specify dut, model, and list to run regressions"
            return
        fi

        if [[ -z ${RTL_PROJ_BIN+x} ]]; then
            echo "Error: need to source dev enviroment first (srcenv)"
            return
        fi

        local test_dir=""
        if [[ ! -z ${4+x} ]]; then
            test_dir="-test_results $4"
        fi

        local command="simregress -dut $1 -model $2 -l $3 -trex -save -trex- -net -P ${EC_SITE}_critical -Q $NBQSLOT $test_dir"
        echo "$command"
        eval "$command"
    }

elif [ "$EC_SITE" == 'fc' ]; then

    build () {
        nbqe simbuild -ace "-c -model $1 -elab_debug_pp"
    }

    waves () {
        acesh -dut dnv "dve -vpd $PWD/soc_tb.vpd"
    }
fi
