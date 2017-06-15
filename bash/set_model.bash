#!/usr/intel/bin/bash

set-model () {
    export MANUAL_MODEL_ROOT=t

    if [ -d "$1" ]; then
        export MODEL_ROOT="$1"
        echo "\$MODEL_ROOT=$MODEL_ROOT"
        return
    fi

    if [ -z "$IP_MODELS" ]; then
        echo "source dev env first (srcenv)"
        return
    fi

    if [ -d "$IP_MODELS/$1" ]; then
        model=$IP_MODELS/$1
    else

        shopt -s nullglob

        options=($IP_MODELS/*${1}*)


        if (( ${#options[@]} == 0 )); then
            echo "no models match $1"
            return
        fi

        if (( ${#options[@]} != 1 )); then
            printf '%s\n' "${options[@]}"
            return
        fi

        model=${options[0]}
    fi

    if [ "$2" ]; then
        # if [ -d $model/$2 ]; then
        #     echo foo
        #     version=${model}/$2
        # else
            shopt -s nullglob
            versions=($model/*${2}*)

            if (( ${#versions[@]} == 0 )); then
                echo "no version matches $model $2"
                return
            fi

            printf '%s\n' "${versions[@]}"

            if (( ${#versions[@]} != 1 )); then
                min=100000
                i=0
                for ver in "${versions[@]}"; do
                    echo "$ver"
                    if (( ${#ver} < $min )); then
                        min=${#ver}
                        i=0
                        shortest_versions[i++]=$ver
                    elif (( ${#ver} == $min )); then
                        shortest_versions[i++]=$ver
                    fi
                done

                echo ""
                echo "i = $i"
                echo ""

                if (( i != 1 )); then
                    echo "requested input $2 resolves to multiple versions"
                    idx=$((i - 1))
                    for j in $(seq 0 $idx); do
                        echo ${shortest_versions[j]}
                    done
                    return
                fi
                version=${shortest_versions[0]}
            else
                version=${versions[0]}
            fi
        # fi

    else
        version=$(readlink -f $model/${model##*/}-srvr10nm-latest)
    fi

    export MODEL_ROOT=$version

    echo "\$MODEL_ROOT=$MODEL_ROOT"

    # cd $prev_dir
}
