#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure docker..."

# Check if iterm exists
if [ $(brew cask ls | grep "docker" | wc -l) -ne 1 ]; then
    e_error "docker is not installed."
    exit 1
fi

echo "hallelujah"

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
