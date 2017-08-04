#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure Git..."

CWD=$(pwd)
ln -sf ${CWD}/git/gitconfig ~/.gitconfig
ln -sf ${CWD}/git/gitignore_global ~/.gitignore_global

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
