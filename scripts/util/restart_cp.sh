#!/usr/intel/pkgs/bash/4.3/bin/bash
# Author  : Troy Hinckley troy.j.hinckley@intel.com
# Created : Feb 28, 2017
# https://e2esm.intel.com/kb_view.do?sysparm_article=KM00034223
# NOTE: this script will disconnect your VNC Viewer, but your session will remain intact

pid=$(pgrep -u "$USER" vncconfig)

if [ ! -z "$pid" ]; then
    echo "vncconfig was running"
    for i in $pid
    do
        kill -9 "$i"
    done
else
    echo "vncconfig was not running"
fi

version=$(iwhich vncserver | awk -F "/" '{print $6}')

xvnc_pid=$(pgrep -u "$USER" Xvnc)
display_number=$(ps "$xvnc_pid" | grep -v PID | awk '{print $6}')

if [ -z "$(vncconfig –display "$display_number" –list)" ]; then
    echo "vncconfig is not responding. You will need to start a new VNC session"
else
    /usr/intel/pkgs/vnc/"$version"/vncconfig -nowin -poll=3000 -display "$display_number" &
    /usr/intel/bin/vncconfig -display "$display_number" –disconnect
fi
