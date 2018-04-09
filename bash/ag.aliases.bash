cite 'about-alias'
about-alias 'the silver searcher (ag) aliases'

# ag --smart-case --pager="less -MIRFX"

if [[ $INSIDE_EMACS ]]; then
    alias ag='ag --follow --search-zip --color-match="1;31" --smart-case'
else
    ## Summary for args to less:
    # less(1)
    #   -M (-M or --LONG-PROMPT) Prompt very verbosely
    #   -I (-I or --IGNORE-CASE) Searches with '/' ignore case
    #   -R (-R or --RAW-CONTROL-CHARS) For handling ANSI colors
    #   -F (-F or --quit-if-one-screen) Auto exit if <1 screen
    #   -X (-X or --no-init) Disable termcap init & deinit
    alias ag='ag --follow --search-zip --color-match="1;31" --smart-case --pager="less -MIRFX"'
fi
