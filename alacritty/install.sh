#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure alacritty..."

# TODO: install alacritty from source here. Maybe.

mkdir -p ~/.config/alacritty/

CWD=$(pwd)
ln -sf ${CWD}/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
