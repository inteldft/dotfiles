#!/usr/intel/bin/bash

_ipci () {
    COMPREPLY=( $(compgen -W "$(ipci ls)" -- "${COMP_WORDS[COMP_CWORD]}") )
}

complete -F _ipci ipci

_perl_script () {
    local file
    file=$(eval echo "$1")
    if [[ ! -f $file ]]; then
        local type=($(type -a "$file"))
        file=${type[2]}
    fi
    COMPREPLY=( $(compgen -W "$(~/scripts/perl_cmd_line.pl "$file")" -- "${COMP_WORDS[COMP_CWORD]}") )
}

perl_scripts=(
    # cdf
    bld_test
    run_convert_scan
    run_convert_espf2spf
    run_convert_stfstf2spf
    run_convert_spf2itpp
    run_refresh_all_tests
    run_generate_scan_10nm
    run_concatenate_itpp
    # chassis_dft_val_global -- scan
    run_generate_scan
    run_generate_scan_10nm
    # chassis_dft_val_global -- spf_scan_tools
    generate_bifurcation_cases
    generate_burnin_broadcast_watchdog_threshold_cases
    generate_burnin_cases
    generate_check_scan_ports
    generate_cmp_exp_cases
    generate_cmp_exp_cases_broadcast
    generate_ctrl_chain_cont_cases
    generate_interleave_cases
    generate_interleave_merge_cases
    generate_multipart_capture_cases
    generate_proxy_cases
    generate_scandump_cases
    generate_scandump_cont_cases
    generate_scoreboard_cases
    generate_wavegen_cases
    # chassis_dft_val_global -- templates
    10nm_proxy_atspeed_capture.skeleton
    10nm_proxy_capture.skeleton
    10nm_proxy_chunking_capture.skeleton
    10nm_proxy_cont.skeleton
    10nm_proxy_ratio_cont.skeleton
    # chassis_dft_val_global -- scripts
    add_creed_restore.pl
    analyze_itpp_errors
    analyze_itpp_errors_v2.pl
    analyze_stf_itpp_errors.pl
    build_spf_list.pl
    gen_stf_network_graph.pl
    gen_taplink_network_graph.pl
    get_spf_straps
    list_equivalent.pl
    prune_cobra_hierarchies.pl
    # ~/bin
    csh-source
    diskhogs
    verdiwaves
)

for i in "${perl_scripts[@]}"
do
    complete -F _perl_script "$i"
done

