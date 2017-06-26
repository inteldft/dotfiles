#!/usr/intel/bin/bash

# set the model root to specified IP and version
# USAGE: set-model [model pattern] <version pattern>
# example: set-model iio 23a
setmodel () {
    export MANUAL_MODEL_ROOT=t

    ###########################
    # get the model of the IP #
    ###########################

    if [[ -d $1 ]]; then
        # if given a directory set model root to that
        export MODEL_ROOT="$1"
        echo "\$MODEL_ROOT=$MODEL_ROOT"
        return
    fi

    if [[ ! $IP_MODELS ]]; then
        echo "source dev env first (srcenv)"
        return
    fi

    shopt -s nullglob

    if [[ -d $IP_MODELS/$1 ]]; then
        # use arg if resolvable IP name
        model=$IP_MODELS/$1

    else
        options=($IP_MODELS/*${1}*)

        if (( ${#options[@]} == 0 )); then
            echo "no models match $1"
            return
        fi

        # mutiple matches for given pattern
        if (( ${#options[@]} != 1 )); then
            printf '%s\n' "${options[@]}"
            return
        fi

        model=${options[0]}
    fi

    #############################
    # get the version of the IP #
    #############################

    if [[ ! $2 ]] || [[ $2 == *latest ]]; then
        # if not specified or 'latest' set model to the latest.
        # resolve the link because the latest pointer can change
        version=$(readlink -f "$model"/"${model##*/}"-srvr10nm-latest)

    elif [[ -d $model/$2 ]]; then
        # if version resolvable, set that version
        version=${model}/$2

    else
        versions=($model/*${2}*)

        if (( ${#versions[@]} == 0 )); then
            echo "no version matches $model $2"
            return
        fi

        if (( ${#versions[@]} == 1 )); then
            version=${versions[0]}

        else
            # get the version of the shortest length, which is usually the one you want
            min=100000
            for ver in "${versions[@]}"; do
                if (( ${#ver} < min )); then
                    min=${#ver}
                    shortest_versions=($ver)
                elif (( ${#ver} == min )); then
                    shortest_versions+=($ver)
                fi
            done

            if (( ${#shortest_versions[@]} > 1 )); then
                echo "requested input $2 resolves to multiple versions"
                printf '%s\n' "${shortest_versions[@]}"
                return
            fi
            version=${shortest_versions[0]}
        fi
    fi

    export MODEL_ROOT=$version

    echo "\$MODEL_ROOT=$MODEL_ROOT"
}
