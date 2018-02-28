#!/usr/bin/env bash

while true
do
    onscreen="$(tmux capture-pane -J -p -t $TMUX_PANE | tail -n1)"
    onscreen_sanatized="$(echo -e "${onscreen}" | sed -e 's/[[:space:]]*$//')"
    if [ "$onscreen_sanatized" == "coreAssembler>" ]; then
        echo -en "\a"
        exit 0
    fi
    sleep 5
done
