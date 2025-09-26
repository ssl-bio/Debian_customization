#!/bin/bash
# 08_sudo_Flatpak_config_installation.sh
# Description: Script to enable the installation of flatpaks and install some.
# Descriptions for each are included above each one.

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo 08_sudo_Flatpak_config_installation.sh

##################
# Load functions #
##################
source Helper_functions.sh

#################
# Get user home #
#################
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
user_name=$(logname)

###########################################
# Define download and script directories #
###########################################
# Script directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

#####################
# Configure flatpak #
#####################
msg 'flatpak' 'Configuring'
apt install flatpak -qy

# Add repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

check_exit_status "${script_dir}/${log_file}"

################################
# Install flatpak-applications #
################################

# Install thunderbird
# msg 'Thunderbird'
# flatpak install flathub org.mozilla.Thunderbird -y
# check_exit_status "${script_dir}/${log_file}"

# Warehouse - Flatpak package manager (GUI)
msg 'Warehouse'
flatpak install flathub io.github.flattool.Warehouse -y
check_exit_status "${script_dir}/${log_file}"

# Buzz - Audio transcription tool using OpenAI Whisper
msg 'Buzz'
flatpak install flathub io.github.chidiwilliams.Buzz -y
check_exit_status "${script_dir}/${log_file}"

# Frog - Extract text from images using OCR technology
msg 'Frog'
flatpak install flathub com.github.tenderowl.frog -y
check_exit_status "${script_dir}/${log_file}"

# Switcheroo - File format converter for images
msg 'Switcheroo'
flatpak install flathub io.gitlab.adhami3310.Converter -y
check_exit_status "${script_dir}/${log_file}"

# Clapgrep - Search for text patterns in your clipboard history
msg 'Clapgrep'
flatpak install flathub de.leopoldluley.Clapgrep -y
check_exit_status "${script_dir}/${log_file}"

# Minder - Create and organize mind maps and diagrams
msg 'Minder'
flatpak install flathub com.github.phase1geo.minder -y
check_exit_status "${script_dir}/${log_file}"

# Devtoolbox - Collection of development tools and utilities
# Format conversion
msg 'Devtoolbox'
flatpak install flathub me.iepure.devtoolbox -y
check_exit_status "${script_dir}/${log_file}"

# Tubefeeder - RSS-like client for YouTube channels and playlists
# msg 'Tubefeeder'
# flatpak install flathub de.schmidhuberj.tubefeeder
# check_exit_status "${script_dir}/${log_file}"
