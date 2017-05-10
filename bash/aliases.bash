#!/usr/bin/env bash

alias d='dir'
alias dir='ls --format=vertical'
alias helpcommand='whatis'
alias l='ll'
# alias man='/usr/intel/bin/tman !* || /usr/bin/man !*'
alias o='less'
# alias remount='/bin/mount -o remount,!*'
alias runx='/usr/intel/common/pkgs/eclogin/1.0/bin/runx'
alias v='vdir'
alias vdir='ls --format=long'
alias wl='less -S -# 15'
alias display='/usr/intel/pkgs/ImageMagick/6.8.9-1/bin/display'

alias timer='/usr/bin/time --format="TIMER: %C finished in %e seconds"'

alias cdm='cd $MODEL_ROOT'
alias sf='$HOME/scripts/smart_find.sh'

alias win-xl='xrandr -s 1920x1200'
alias win-l='xrandr -s 1920x1080'
alias win-m='xrandr -s 1536x864'

if [ "$EC_SITE" == 'sc' ]; then
    alias srcenv='source /p/hdk/rtl/cad/x86-64_linux26/intel/Modules/3.2.10.2/init/bash; module load lv_cfg; unset module; export NBQSLOT=/SDG/sdg74/fe/build/chassis; export NBCLASS=SLES11SP4\&\&20G; export NBPOOL=sc_critical'
    # alias srcenv='wash -g user -n soc socenv dnv socrtl soc73 srvr10nm hdk10nm shdk73 -- -c "tcsh -c '\''source ~/custom/env_aliases.csh ; source /p/hdk/rtl/hdk.rc -cfg shdk74 ; setenv NBQSLOT /SDG/sdg74/fe/build/chassis ; setenv NBCLASS SLES11SP4\&\&20G ; setenv nbpool sc_critical ; exec bash'\''"'
elif [ "$EC_SITE" == 'fc' ]; then
    alias srcenv='wash -g user -n soc socenv dnv socrtl soc73 srvr10nm hdk10nm shdk73 -- -c "tcsh -c '\''source /p/hdk/rtl/hdk.rc -cfg shdk73 ; setenv NBQSLOT /SDG/sdg74/fe/build/chassis ; setenv NBCLASS SLES11SP4\&\&20G ; setenv NBPOOL fc_critical ; exec bash'\''"'
fi

alias setroot='export MODEL_ROOT=`$HOME/scripts/set_root.sh`'
alias tool-config='ToolConfig.pl get_tool_env spyglass | cut -f 2,3,4 -d " " | source /dev/stdin'

alias ipgen='(~/scripts/ipgen_start.sh $MODEL_ROOT) && source setup && (~/scripts/ipgen_finish.sh $MODEL_ROOT $DFT_REPO_ROOT) || ipgen-reset'
alias ipgen-reset='~/scripts/ipgen_reset.sh $MODEL_ROOT'
alias xterm-custom='xterm -fs 11 -u8'

alias notify-home='exit_code=PASSED || exit_code=FAILED ; $HOME/scripts/notify-home.sh $exit_code'
alias notify-work='exit_code=PASSED || exit_code=FAILED ; $HOME/scripts/notify-work.sh $exit_code'
alias notify-all='exit_code=PASSED || exit_code=FAILED ; $HOME/scripts/notify-all.sh $exit_code'

alias check='nbqstat -P $NBPOOL --task-name --priority user=$USER'

alias rp='realpath'

alias dsync='$HOME/.dotfiles/dotsync/bin/dotsync'
alias man-root-mode='export MANUAL_MODEL_ROOT=t'
alias print-path='echo $PATH | tr : '\''\n'\'''
