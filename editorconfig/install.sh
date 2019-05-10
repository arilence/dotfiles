#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure EditorConfig..."

CWD=$(pwd)
ln -sf ${CWD}/editorconfig/editorconfig ~/.editorconfig

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
