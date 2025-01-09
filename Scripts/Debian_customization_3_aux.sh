#!/bin/bash
# Debian_customization_2_aux.sh
# Description: Accompanying script for Debian_customization_3.sh used to
# install yazi (file manager)

# Execution: If ran separately it needs to be run as a regular user
# > Debian_customization_3_aux.sh

##################
# Load functions #
##################
source Helper_functions.sh

msg 'Installing Rust...'
# Install rust https://rustup.rs/
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
check_exit_status

# Load Rust environment
source "$HOME/.cargo/env"

msg 'Installing Yazi...'
# Install Yazi from crates.io
cargo install --locked yazi-fm yazi-cli
check_exit_status
