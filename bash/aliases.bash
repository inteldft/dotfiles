#!/usr/bin/env bash

alias o='less'
alias wl='less -S -# 15'
alias rp='realpath'
alias cdm='cd $MODEL_ROOT'

alias timer='/usr/bin/time --format="TIMER: %C finished in %e seconds"'

alias win-xl='xrandr -s 1920x1200'
alias win-l='xrandr -s 1920x1080'
alias win-m='xrandr -s 1536x864'

if [[ $EC_SITE == 'fc' ]]; then
    alias srcenv='eval $(csh-source -inline -noalias /p/hdk/rtl/hdk.rc -cfg shdk73)'
else
    alias srcenv='source /p/hdk/rtl/cad/x86-64_linux26/intel/Modules/3.2.10.2/init/bash; module load lv_cfg; unset module'
fi

alias ports='netstat -lptu'
alias xterm-custom='xterm -fs 11 -u8'

alias notify-home='exit_code=PASSED || exit_code=FAILED ; $HOME/scripts/notify-home.sh $exit_code'
alias notify-work='exit_code=PASSED || exit_code=FAILED ; $HOME/scripts/notify-work.sh $exit_code'
alias notify-all='exit_code=PASSED || exit_code=FAILED ; $HOME/scripts/notify-all.sh $exit_code'

alias check='nbqstat -P $NBPOOL --task-name --priority user=$USER'

alias dsync='$HOME/.dotfiles/dotsync/bin/dotsync'
alias man-root-mode='export MANUAL_MODEL_ROOT=t'
alias print-path='echo $PATH | tr : '\''\n'\'''
