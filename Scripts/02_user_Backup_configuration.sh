#!/bin/bash
# 02_user_Backup_configuration.sh
# Description: Script to create a backup of
# the default configuration for the following elements:
# Keybindings (Tilix), Configuration (Compiz, Quicktile, Panels) 

# Execution: If ran separately it needs to be run as a regular user
# > ./02_user_Backup_configuration.sh

##################
# Load functions #
##################
source Helper_functions.sh

###########################################
# Define download and script directories #
###########################################
# Script directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

#################################
# Backup Tilix configuration.  #
#################################
msg 'Tilix configuration' 'Backup'

# Backup default settings
# Keybindings
dconf dump /com/gexperts/Tilix/keybindings/ > "${config_dir}"/tilix/tilix_default_keybindings
# Profiles
dconf dump /com/gexperts/Tilix/profiles/ > "${config_dir}"/tilix/tilix_default_profiles

check_exit_status "${script_dir}/${log_file}"

#################
# Backup Compiz #
#################
msg 'Compiz configuration' 'Backup'
# Backup profile
backup_file="${config_dir}"/compiz/compiz_bookworm_default.profile
if [ ! "$backup_file" ]; then
    dconf dump /org/compiz/ > "$backup_file"
fi

check_exit_status "${script_dir}/${log_file}"

#####################
# Backup Quicktile #
######################
msg 'Quicktile configuration' 'Backup'
# Generate configuration file, create a backup and overwrite
# with the one from the customization repo
config_file="$HOME"/.config/quicktile.cfg
if [ ! -f "$config_file" ]; then
    quicktile --daemonize &
    cp "$config_file" "$HOME"/.config/quicktile.cfg_bk0
fi

check_exit_status "${script_dir}/${log_file}"
#########################
# Backup panel settings #
#########################
msg 'Panel configuration' 'Backup'
backup_file="${config_dir}"/Mate_DE/panel/mate-panel-debian-default-backup.dconf
if [ ! -f "$backup_file" ]; then
    # Backup default configuration
     dconf dump /org/mate/panel/ > "$backup_file"
fi

check_exit_status "${script_dir}/${log_file}"
