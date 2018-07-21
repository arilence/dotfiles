#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure Python..."

if ! type_exists 'pip3'; then
    e_warning "pip3 was not found, skipping."
else
    pip3 install -q --user -r ./python/requirements-3.txt
fi

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
