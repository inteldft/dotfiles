#!/usr/intel/bin/bash

# Script for installing Fish Shell on systems without root access.
# Fish Shell will be installed in $HOME/local/bin.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

FHISH_SHELL_VERSION=2.1.1

# create our directories
mkdir -p $HOME/local $HOME/fish_shell_tmp
cd $HOME/fish_shell_tmp

# download source files for Fish Shell
wget http://fishshell.com/files/${FHISH_SHELL_VERSION}/fish-${FHISH_SHELL_VERSION}.tar.gz

# extract files, configure, and compile

tar xvzf fish-${FHISH_SHELL_VERSION}.tar.gz
cd fish-${FHISH_SHELL_VERSION}
./configure --prefix=$HOME/local --disable-shared
make
make install
