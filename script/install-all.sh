#!/usr/bin/env bash
# This script manages / executes install scripts found
# within each module of my dotfiles.

find ./ \
    -not -path "*/script/*" \
    -maxdepth 2 \
    -type f \
    -name 'install.sh' \
    -exec ./{} \;
