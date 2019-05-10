#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure Gnupg..."

mkdir -p ~/.gnupg/
CWD=$(pwd)
ln -sf ${CWD}/gnupg/gpg-agent.conf  ~/.gnupg/gpg-agent.conf
ln -sf ${CWD}/gnupg/gpg.conf  ~/.gnupg/gpg.conf

if [ $? -ne 0 ]; then
  e_error "Configuration failed!"
  exit 1
fi
e_success "Success."
