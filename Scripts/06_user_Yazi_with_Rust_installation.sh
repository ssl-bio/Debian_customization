#!/bin/bash
# 06_user_Yazi_with_Rust_installation.sh
# Description: Script to install yazi (file manager for the cli)
# It requires Rust 

# Execution: If ran separately it needs to be run as a regular user
# > ./06_user_Yazi_with_Rust_installation.sh

##################
# Load functions #
##################
source Helper_functions.sh

######################
# Define directories #
######################
# Script directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

################
# Install Rust #
################
msg 'Rust'
# Install rust https://rustup.rs/
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
check_exit_status "${script_dir}/${log_file}"

# Load Rust environment
source "$HOME/.cargo/env"

################
# Install Yazi #
################
msg 'Yazi'
# Install Yazi from crates.io
cargo install --locked yazi-fm yazi-cli
check_exit_status "${script_dir}/${log_file}"
