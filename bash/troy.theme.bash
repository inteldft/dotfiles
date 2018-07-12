#!/usr/intel/bin/bash

__cel_cwd() {

    local DIR=${PWD/$HOME/\~}

    DIR=${DIR/\/nfs\/sc\/disks\/sdg74_1185\/tjhinckl/\~}
    DIR=${DIR/\/nfs\/fc\/disks\/shdk73_0132\/tjhinckl/\~}

    local names=(${DIR//\// })

    local base=${names[-1]}
    unset "names[${#names[@]}-1]"

    for i in "${!names[@]}"; do
        names[$i]=${names[$i]:0:$BASH_PROMPT_PWD_DIR_LENGTH};
    done

    names+=($base)
    DIR=$(IFS="/" ; echo "${names[*]}")
    if [[ ${DIR:0:1} != "~" ]]; then
        DIR="/$DIR"
    fi

    echo "${blue}$DIR${normal}"
}

get_exit_code() {
    exit_code=$?
    __code_st=""
    if [[ $exit_code != 0 ]]; then
        __code_st="[${bold_red}✘${normal}]"
    fi
}

__cel_env_setup() {
    if [[ $PATH =~ proj_tools ]]; then
        echo "${green}◉${normal}"
    fi
}

function timer_start {
    timestamp=${timestamp:-$(($(date +%s%N)/1000000))}
}


trap 'timer_start' DEBUG
PS3=">> "

__cmd_time () {
    local ms=$timer_show
    local sec=$(echo "scale=1; ($ms - 200)/1000" | bc)
    local min=$(echo "scale=1; $sec/60" | bc)
    local hour=$(echo "scale=1; $min/60" | bc)

    if [ "$(echo "$hour > 1" | bc)" == 1 ]; then
        echo "[${orange}${hour}h${normal}]";
    elif [ "$(echo "$min > 1" | bc)" == 1 ]; then
        echo "[${yellow}${min}m${normal}]";
    elif [ "$(echo "$sec >= 1" | bc)" == 1 ]; then
        echo "[${normal}${sec}s${normal}]";
    fi
}

prompt_command() {
    timer_show=$(($(($(date +%s%N)/1000000)) - $timestamp))
    unset timestamp
    PS1="\n╭─$__code_st$(__cmd_time)[$(__cel_cwd)]$(__cel_env_setup)\n╰─→ "

}

PS2='╰─→ '
