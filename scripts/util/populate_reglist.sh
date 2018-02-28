#!/usr/intel/pkgs/bash/4.3/bin/bash

if [ -z "$STF_SPFSPEC" ]; then
    echo "you need to set the dft variables first (setdftvars)"
    exit
fi


# recursive=0
test_type='dft'
# if [ "$1" == '-r' ]; then
#     recursive=1
#     if [[ ! -z ${2+x} ]]; then
#         test_type="$2"
#     fi
# elif [[ ! -z ${1+x} ]]; then
#     test_type="$1"
# fi

dut_name=$(grep -oP '(?<=url = /p/hdk/rtl/git_repos/shdk74/ip/)[a-z0-9_]+(?=-srvr10nm.*)' "$MODEL_ROOT"/.git/config)
dut_name=${dut_name##*$'\n'} # get only the first match

test_file="${PWD##*/}"_tests.list # this list will contain only the tests
> "$test_file" # clear the list in case it already exists

IFS="$(printf '\n\t')" #remove space to keep glob from choking
for file in ./*.itpp ; do
    if [ -f "$file" ]; then
        # fill the test file with the tests. This loop will set the testname and dirtag
        file_name=$(basename "$file")
        file_path=$(sed "s|$MODEL_ROOT|\$MODEL_ROOT|g" <<< "$(realpath "$file")")
        # {test_type}_itpp_test=$([ "$dut_name" == 'scf_iocoh' ] && echo 'scan_itpp_test' || echo 'dft_itpp_test')
        trailer=$([ "$dut_name" == 'scf_iocoh' ] && echo '-c 1000000000')
        echo "${test_type}_itpp_test -ovm_test ${test_type}_itpp_test -ace_args -simv_args '+ITPP_FILE=${file_path}' -ace_args- -dirtag ${file_name%.*} $trailer" >> "$test_file"
    fi
done

model_name=$(grep -oP '(?<=spf/)[a-z0-9_]+(?=.stf.spfspec)' <<< "$STF_SPFSPEC") # extract all model name matches
model_name=${model_name##*$'\n'} # get only the first match
run_file="$model_name"_"${PWD##*/}"_regression.list # the file that contains all the options and defaults to run correctly
cp ~/custom/reglist_templates/"$dut_name".list "$run_file"

#remove database files for faster runs and smaller footprint
if [ "$1" == '--no_fsdb' ]; then
    sed -i "/fsdb/Id" "$run_file"
fi

# add the test list to the run file as an include
include_path=$(sed "s|$MODEL_ROOT|\$MODEL_ROOT|g" <<< "$(realpath "$test_file")")
echo ".include $include_path" >> "$run_file"
