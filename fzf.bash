# Setup fzf
# ---------
if [[ ! "$PATH" == */nfs/site/home/tjhinckl/.fzf/bin* ]]; then
  export PATH="$PATH:/nfs/site/home/tjhinckl/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/nfs/site/home/tjhinckl/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/nfs/site/home/tjhinckl/.fzf/shell/key-bindings.bash"

