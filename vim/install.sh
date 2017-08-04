#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure Vim..."

mkdir -p ~/.config/nvim/
mkdir -p ~/.vim/

CWD=$(pwd)
ln -sf ${CWD}/vim/* ~/.config/nvim/
ln -sf ${CWD}/vim/* ~/.vim/
ln -sf ${CWD}/vim/init.vim ~/.vimrc

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
