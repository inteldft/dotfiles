#!/usr/bin/env bash

HPWD="$(basename $(dirname $(dirname $(dirname "$PWD"))))/$(basename $(dirname $(dirname "$PWD")))/$(basename $(dirname "$PWD"))/$(basename "$PWD")"
HOME_PATH="$(sed 's/nfs\/site\/home\/tjhinckl/~/' <<< $HPWD)"
TOP_PATH="$(sed 's/\([/]\)\1\+/\1/' <<< $HOME_PATH)"
# regular colors
K="\033[0;30m"    # black
R="\033[0;31m"    # red
G="\033[0;32m"    # green
Y="\033[0;33m"    # yellow
B="\033[0;34m"    # blue
M="\033[0;35m"    # magenta
C="\033[0;36m"    # cyan
W="\033[0;37m"    # white

# unset the colors
NONE="\033[0m"    # unsets color to term's fg color

printf "\n${G}[${B}$TOP_PATH${G}]${NONE}\n"
