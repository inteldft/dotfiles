#!/usr/bin/env bash

alias wl='less -S -# 15'
alias rp=realpath
alias cdm='cd $MODEL_ROOT'

alias timer='/usr/bin/time --format="TIMER: %C finished in %e seconds"'

alias win-xl='xrandr -s 1920x1200'
alias win-l='xrandr -s 1920x1080'
alias win-m='xrandr -s 1536x864'

if [[ $EC_SITE == 'fc' ]]; then
    alias srcenv='eval $(csh-source -inline -noalias /p/hdk/rtl/hdk.rc -cfg shdk73)'
else
    alias srcenv='eval $(csh-source -inline -noalias /p/hdk/rtl/hdk.rc -cfg shdk74)'
    # source /p/hdk/rtl/cad/x86-64_linux26/intel/Modules/3.2.10.2/init/bash; module load lv_cfg; unset module
fi

alias phases='gzgrep "started\." acerun.log* | grep sla_tb_env | cut -d"@" -f2'
alias ports='netstat -lptu'
alias reload-fonts='fc-cache -fv'

alias check='nbqstat -P $NBPOOL --task-name --priority user=$USER'

alias dsync='$HOME/.dotfiles/dotsync/bin/dotsync'
alias man-root-mode='export MANUAL_MODEL_ROOT=t'
alias print-path='echo $PATH | tr : '\''\n'\'''
alias busy="lsof +D"
alias mem-usage='ps aux --sort -rss'
alias code-review='/usr/intel/pkgs/ccollab/7.3.7302/ccollabgui &'
alias mpar='ag --nonumbers focus_stf | sort | uniq'

alias real-failures="ag --search-zip --depth 1 -G postsim.log -l '(?:requiredtext not found:|jtagbfm|stf_bfm_agent)'"
