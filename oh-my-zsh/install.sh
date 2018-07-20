#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure Oh My Zsh..."

rm -r ~/.oh-my-zsh/custom
mkdir -p ~/.oh-my-zsh/custom

CWD=$(pwd)
ln -sf ${CWD}/oh-my-zsh/zshrc ~/.zshrc
ln -sf ${CWD}/oh-my-zsh/custom/* ~/.oh-my-zsh/custom/

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi

touch ~/.hushlogin
e_success "Success."
