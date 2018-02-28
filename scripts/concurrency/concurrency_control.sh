#!/bin/bash

aquire_mutex() {
    retval=""
    local mutex_name="$1"
    if [ ! -d ~/temp/resources/mutex/$model ]; then
        mkdir ~/temp/resources/mutex/$model
    fi
    if  mkdir ~/temp/resources/mutex/$model/$mutex_name > /dev/null 2>&1
    then
        touch "$HOME/temp/resources/mutex/$model/$mutex_name/$subsystem"
        retval="true"
    else
        retval="false"
    fi
    echo "$retval"
}

release_mutex() {
    local mutex_name="$1"
    if [ -f ~/temp/resources/mutex/$model/$mutex_name/$subsystem ]; then
        rm -rf ~/temp/resources/mutex/$model/$mutex_name
    fi
}

wait_for_mutex() {
    local mutex_name="$1"
    while [[ $( aquire_mutex $mutex_name $model $subsystem ) == "false" ]]
    do
        sleep 1
    done
}

add_semaphore() {
    local sem_name="$1"
    if [ ! -d ~/temp/resources/semaphore/grouped/$model ]; then
        mkdir ~/temp/resources/semaphore/grouped/$model
    fi
    if [ ! -d ~/temp/resources/semaphore/grouped/$model/$sem_name ]; then
        mkdir ~/temp/resources/semaphore/grouped/$model/$sem_name
    fi
    touch ~/temp/resources/semaphore/grouped/$model/$sem_name/$subsystem

}

remove_semaphore() {
    local sem_name="$1"
    if [ -f ~/temp/resources/semaphore/grouped/$model/$sem_name/$subsystem ]; then
        rm ~/temp/resources/semaphore/grouped/$model/$sem_name/$subsystem
    fi
}

check_semaphore_empty() {
    retval=""
    local sem_name="$1"
    local group_size=0
    group_size=$(ls ~/temp/resources/semaphore/grouped/$model/$sem_name | wc -l)
    if [ $group_size == 0 ]; then
        retval="true"
    else
        retval="false"
    fi
    echo "$retval"
}

wait_for_semaphore_empty() {
    local sem_name="$1"
    local mutex_name="$2"
    while true
    do
        wait_for_mutex $mutex_name
        if [ "$( check_semaphore_empty $sem_name $model )" == "true" ]; then
            return 0
        fi
        release_mutex $mutex_name $model $subsystem
        sleep 1
    done
}
