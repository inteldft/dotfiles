#!/bin/sh
. "/nfs/site/home/tjhinckl/scripts/concurrency_control.sh"
set -e
subsystem=${PWD##*/}
model_root=$1

if [ ! -d $model_root ]; then
    echo "ERROR: MODEL_ROOT not set" 1>&2
    exit 1
fi

set -x

if [ -d collage_work ]; then
    rm -rf collage_work
fi

$model_root/scripts/fixup_ipgen.pl -dut $subsystem -unfix
