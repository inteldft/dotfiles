#!/usr/intel/bin/bash


munge () { # prevent duplicates in aggregate variables
    local args=("$@")
    local cmd_form end
    for i in "${args[@]}"; do
        [[ $i == '-cmd' ]] && cmd_form=1
        [[ $i == '-end' ]] && end=1
    done
    local vars=(${args[@]:$((cmd_form + end))})

    if (( ${#vars[@]} < 2 )); then
        echo "USAGE: munge [-end|-cmd] VAR path/to/add"
        return
    fi

    local var=${vars[0]}
    local path=${vars[1]}
    local delim

    [[ $cmd_form ]] && delim='\s*;\s*' || delim=:
    if ! [[ ${!var} =~ (^|$delim)$path($|$delim) ]]; then
        [[ $cmd_form ]] && delim='; '
        if [[ ! ${!var} ]]; then
            export ${var}=$path
        elif [[ $end ]]; then
            [[ ${!var} == *\; ]] && delim=' '
            export ${var}="${!var}${delim}${path}"
        else
            export ${var}="${path}${delim}${!var}"
        fi
    fi
}

# print out the size of all files/directories in the specified directory and sort them by size
dir-size () {
    du -a -h --max-depth=1 "${1:-.}" | sort -h
}

man() {
    /usr/intel/bin/tman "$@" || /usr/bin/man "$@"
}

# source a C-shell script
csrc() {
    eval "$(csh-source --inline "$@")"
}

count() {
    find "${1:-.}" -maxdepth 1 -type f | wc -l
}

rename() {
    if [[ ! $1 ]]; then
        echo "USAGE: rename <perl substitution regex>"
        return
    fi

    if [[ ! $1 =~ s/.+/.*/.* ]]; then
        echo "ERROR: regex must be of the form 's/<pattern>/<replacement>/<flags>'"
        return
    fi

    perl -we "for (glob '*') { (my \$name = \$_) =~ $1; rename(\$_, \$name) if (\$name ne \$_); }"
}

rm-old () {
    if [[ ! $1 ]]; then
        echo "USAGE: rm-old <number of days to keep> <optional directory>"
        return
    fi
    echo "Removing files older than $1 day(s) in ${2-cwd}"
    find "${2:-.}" -maxdepth 1 -ctime +"$1" -exec rm -rf {} \;
    # find "${2:-.}" -maxdepth 1 -ctime +"$1" | xargs rm -rf
}

mdcd () {
    if [[ ! $1 ]]; then
        echo "must specify a directory"
        return
    fi
    mkdir -p "$1"
    cd "$1" || return
}

sync-site () {
    if [[ ! $1 ]]; then
        echo "need to specify a directory"
        return
    fi

    if [[ $EC_SITE == 'sc' || $EC_SITE == 'pdx' ]]; then
        local remote_host='fcab1249.fc'
    elif [[ $EC_SITE == 'fc' ]]; then
        local remote_host='scci19347.sc'
    else
        echo "remote host unresolved"
        return
    fi

    export REMOTE_HOST=$remote_host
    local cmd="rsync -az $1 ${remote_host}.intel.com:$1"
    eval "$cmd"
}

# tell me which version of an intel IP I am using
whichip () {
    ToolConfig.pl get_tool_path "$1"
}

srcspf () {
    if [[ $1 == 'latest' ]] || [[ ! -d $MODEL_ROOT ]]; then
        SPF_ROOT=/p/hdk/cad/spf/latest
    else
        SPF_ROOT=$(whichip espf)
    fi

    export SPF_ROOT
    csrc -noalias -ignore_msg setenv "$SPF_ROOT"/bin/spf_setup_env
}

# set the vars required to run ESPF on Chassis
setchassisvars () {
    if [[ ! $1 ]]; then
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
if [[ $EC_SITE == 'sc' ]]; then
    setdftvars () {
        if [[ ! $1 ]]; then
            echo "Error: Need to provide a model to set dft variables"
            return
        fi

        if [[ ! $RTL_PROJ_LIB ]]; then
            srcenv
        fi

        if [[ ! -f "$MODEL_ROOT/tools/ipgen/$1" ]]; then
            echo "Error: DUT $1 does not exists"
            return
        fi

        export XWEAVE=$MODEL_ROOT/tools/ipgen/${1}/output/xweave/design_report.json
        if [[ -f $XWEAVE ]]; then
            export STF_SPFSPEC=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.stf.spfspec
            export TAP_SPFSPEC=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.tap.spfspec
            export TAP2STF_MAP_FILE=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.tap2stf.map
            XWEAVE_REPO_ROOT=$(whichip ipconfig/xweave)
            export XWEAVE_REPO_ROOT
        else # wave 3 collateral locations
            export STF_SPFSPEC=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/spf/${1}.stf.spfspec
            export TAP_SPFSPEC=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/spf/${1}.tap.spfspec
            export TAP2STF_MAP_FILE=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/spf/${1}.tap2stf.map
            export XWEAVE=$MODEL_ROOT/tools/ipgen/${1}/output/dft/verif/xweave/design_report.json
        fi
        export REGLIST_DIR=$MODEL_ROOT/verif/reglist/${1}/dft
        export ESPF_DIR=${ESPF_DIR-${HOME}/workspace/chassis_dft_val_global/spf_sequences.1p0/scan}
        export DFT_GLOBAL_DIR=${DFT_GLOBAL_DIR-${HOME}/workspace/chassis_dft_val_global}
        if [[ $LD_LIBRARY_PATH ]];  then
            unset LD_LIBRARY_PATH
        fi
        srcspf

    }

    setsnrvars () {
        if [[ ! $1 ]]; then
            echo "Error: Need to provide a model to set dft variables"
            return
        fi

        if [[ ! $RTL_PROJ_LIB ]]; then
            srcenv
        fi

        export STF_SPFSPEC=$MODEL_ROOT/subIP/snr/dft_ipgen_snr/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.stf.spfspec
        export TAP_SPFSPEC=$MODEL_ROOT/subIP/snr/dft_ipgen_snr/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.tap.spfspec
        export TAP2STF_MAP_FILE=$MODEL_ROOT/subIP/snr/dft_ipgen_snr/tools/ipgen/${1}/output/dft/verif/rtl/spf/${1}.tap2stf.map
        export XWEAVE=$MODEL_ROOT/subIP/snr/dft_ipgen_snr/tools/ipgen/${1}/output/xweave/design_report.json
        export ESPF_DIR=${ESPF_DIR-${HOME}/workspace/chassis_dft_val_global/spf_sequences.1p0/scan}
        export DFT_GLOBAL_DIR=${DFT_GLOBAL_DIR-${HOME}/workspace/chassis_dft_val_global}
        XWEAVE_REPO_ROOT=$(whichip ipconfig/xweave)
        export XWEAVE_REPO_ROOT
        if [[ $LD_LIBRARY_PATH ]];  then
            unset LD_LIBRARY_PATH
        fi
        srcspf

    }

    _setdftvars () {
        shopt -s nullglob
        local canidates=($MODEL_ROOT/tools/ipgen/*/)
        canidates=("${canidates[@]%/}")
        local cur=${COMP_WORDS[COMP_CWORD]}
        # shellcheck disable=SC2116
        COMPREPLY=( $(compgen -W "$(echo "${canidates[@]##*/}")" -- "$cur") )
    }

    complete -F _setdftvars setdftvars

else
    setdftvars () {
        if [[ ! $RTL_PROJ_LIB ]]; then
            srcenv
        fi

        export STF_SPFSPEC=$MODEL_ROOT/verif/tests/JTAG_BFM_CTT_files/spf/dnv.stf.spfspec
        export TAP_SPFSPEC=$MODEL_ROOT/verif/tests/JTAG_BFM_CTT_files/spf/dnv.tap.spfspec
        export TAP2STF_MAP_FILE=$MODEL_ROOT/verif/tests/dft/source_stfstf/dnv.topo
        export REGLIST_DIR=$MODEL_ROOT/verif/tests/lists/regression
        export ESPF_DIR=$MODEL_ROOT/verif/tests/dft/source_scan_10nm
        export ITPP_DIR=$MODEL_ROOT/verif/tests/dft/itpp
        export DFT_GLOBAL_DIR=${DFT_GLOBAL_DIR-${HOME}/workspace/chassis_dft_val_global}

        unset LD_LIBRARY_PATH
        srcspf latest
    }
fi

# interpret Netbatch exit codes
nbexit () {
    nbstatus --tar linux1 constants --fo csv numericvalue=="$1"
}

if [[ $EC_SITE == 'sc' || $EC_SITE == 'pdx' ]]; then
    build-local () {
        if (( $# < 2 )); then
            echo "Error: must specify dut and mc to build"
            return
        fi

        if [[ ! $RTL_PROJ_LIB ]]; then
            srcenv
        fi

        if [[ $3 ]]; then
            local stages="-s all +s $3"
        fi

        shopt -s extglob
        if [[ $3 == @(sgdft|sglp) ]]; then
            local postfix="-1c -dut $1 -1c-";
        fi

        local command="bman -dut $1 -mc $2 $stages $postfix"
        echo "$command"
        eval "$command"
    }

    build () {
        if (( $# < 2 )); then
            echo "Error: must specify dut and mc to build"
            return
        fi

        if [[ ! $RTL_PROJ_LIB ]]; then
            srcenv
            return
        fi

        if [[ $3 ]]; then
            local stages="-s all +s $3"
        fi

        shopt -s extglob
        if [[ $3 == @(sgdft|sglp) ]]; then
            local postfix="-1c -dut $1 -1c-";
        fi

        local command="$GK_CONFIG_DIR/hooks/setup_git_config.pl -c $1; nbjob run --target ${EC_SITE}_critical --mail E bman -dut $1 -mc $2 $stages $postfix"
        echo "$command"
        eval "$command"
    }

    waves () {
        if (( $# < 2 )); then
            echo "Error: must specify dut and model to pull up waves"
            return
        fi

        if [[ ! $RTL_PROJ_BIN ]]; then
            srcenv
        fi

        local fsdb=()
        if [[ $3 ]]; then
            fsdb=(-f $3)
        fi

        verdiwaves -dut "$1" -m "$2" "${fsdb[@]}" "${@:4}"
    }

    rem-waves () {
        if (( $# < 2 )); then
            echo "Error: must specify dut and model to pull up waves"
            return
        fi

        if [[ ./ -ef ~ ]]; then
            echo "Error: can't run remote verdi session from homedisk"
            return
        fi

        if [[ ! $RTL_PROJ_BIN ]]; then
            srcenv
        fi

        if [[ ! -f "$MODEL_ROOT/target/$1/vcs_4value/$2/$2.simv" ]]; then
            echo "Error: $MODEL_ROOT/target/$1/vcs_4value/$2/$2.simv does not exist!"
            return
        fi

        if (($# == 3)) && [[ ! -f $3 ]]; then
            echo "Error: fsdb file: $2 does not exist."
            return
        fi

        nbjob run --target "${EC_SITE}"_normal3 --qslot /SDG/sdg74/fe/rgr/snr/regress --class 'SLES11SP4&&40G' --mode interactive ~/scripts/run_verdi.csh "$1" "$2" "$3"
    }

    reg () {

        if (( $# < 3 )); then
            echo "Error: must specify dut, model, and list to run regressions"
            return
        fi

        if [[ ! $RTL_PROJ_BIN ]]; then
            srcenv
        fi

        # if [[ ! -w $MODEL_ROOT ]] && (( $# < 4 )); then
        #     echo "Error: must specify result directory when running on remote models"
        #     return
        # fi

        if [[ $4 ]]; then
            local test_dir="-test_results $4"
        fi

        local command="simregress -dut $1 -model $2 -l $3 -save -net -P ${EC_SITE}_critical -Q /SDG/sdg74/fe/build/chassis -C 'SLES11SP4&&32G' $test_dir"
        echo "$command"
        eval "$command"
    }

elif [[ $EC_SITE == 'fc' ]]; then

    build () {
        nbqe simbuild -ace "-c -model $1 -elab_debug_pp"
    }

    waves () {
        acesh -dut dnv "dve -vpd $PWD/soc_tb.vpd"
    }
fi
