#!/usr/intel/bin/bash
. "/nfs/site/home/tjhinckl/scripts/concurrency_control.sh"
set -e

subsystem=${PWD##*/}
model_root=$1
model=${model_root##*/}

echo "RESETING LOCKS FOR $subsystem..."

if [ -f ~/temp/resources/pid/$model/$subsystem ]; then
    pid=$(cat ~/temp/resources/pid/$model/$subsystem)
    if kill -9 "$pid" > /dev/null 2>&1; then
       echo "killed listener process $pid"
    fi
fi

release_mutex mcchan_power_domain

echo "RESET COMPLETE"
