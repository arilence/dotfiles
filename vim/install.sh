#!/usr/bin/env bash

# Many neovim plugins require the python-neovim bridge to be installed
if test $(which pip3); then
  pip3 install -q --user neovim
fi

# Install the vim-plug plugins
vim +PlugInstall +qall
