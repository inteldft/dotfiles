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
alias valid-json='python3.6.3 -m json.tool >/dev/null < '

alias run_dft_ipgen='$DFT_REPO_ROOT/DFTNetworkGen/run_dft_ipgen'

alias real-failures="echo 'BFM failure:'; ag --search-zip --depth 1 -G postsim.log -l '(?:jtagbfm|stf_bfm_agent)'; echo 'early termination:'; ag --search-zip --depth 1 -G postsim.log -l '(?:requiredtext not found:)'"
alias stf-packets="ag --search-zip --nonumbers '(?:^ovm_error.+?stf_bfm_driver|^actual: |^expect: |^  mask: |^ovm_info.+?\[spf_itpp_parser_info\] \(\d+\)|^ovm_info.+?stf_bfm_driver.+?expected packet passed)' acerun.log.gz"
alias spftmp='for i in *.espf; do $SPF_ROOT/bin/spf_perl_pp -stfSpecFile $STF_SPFSPEC -tapSpecFile $TAP_SPFSPEC -testSeqFile $i --itppFile $i.itpp --templateFile $DFT_GLOBAL_DIR/spf_sequences.1p0/tap/sub_system/TAP ; done'

alias use-spacemacs='ln -nsfv /nfs/site/home/tjhinckl/custom/spacemacs-emacs ~/.emacs.d'
alias use-custom='ln -nsfv /nfs/site/home/tjhinckl/custom/emacs.d ~/.emacs.d'
