#!/bin/bash
# Debian_customization_1_aux.sh
# Description: Accompanying script for Debian_customization_1.sh used to
# setup Compiz, Tilix, and Quicktile as a regular user

# Execution: If ran separately it needs to be run as a regular user
# > Debian_customization_1_aux.sh

##################
# Load functions #
##################
source Helper_functions.sh

 #################################################
 # Define download and customization directories #
 #################################################
# Download directory
idownload="$HOME/Download_installation"
if [ ! -d "$idownload" ]; then 
    mkdir -p "$idownload"
fi

# Customization directory
custom_dir="$HOME"/Debian_customization
config_dir=${custom_dir}/Configuration_files

#################################
# Restore Tilix configuration.  #
#################################
msg 'Restoring Tilix configuration...'

# Backup default settings
# Keybindings
dconf dump /com/gexperts/Tilix/keybindings/ > "${config_dir}"/tilix/tilix_default_keybindings
# Profiles
dconf dump /com/gexperts/Tilix/profiles/ > "${config_dir}"/tilix/tilix_default_profiles

# Replace custom settings
# Keybidings
dconf load /com/gexperts/Tilix/keybindings/ < "${config_dir}"/tilix/tilix_custom_keybindings
# Profiles
dconf load /com/gexperts/Tilix/profiles/ < "${config_dir}"/tilix/tilix_custom_profiles

check_exit_status

################
# Setup Compiz #
################
msg 'Setting up Compiz...'
# Backup profile
backup_file="${config_dir}"/compiz/compiz_bookworm_default.profile
if [ ! "$backup_file" ]; then
    dconf dump /org/compiz/ > "$backup_file"
fi

# Replace profile with custom one
 dconf load /org/compiz/ < "${config_dir}"/compiz/compiz_bookworm_custom.profile.

# Load Compiz
 # compiz --replace &

check_exit_status

#####################
# Configure Quicktile #
######################
msg 'Configuring Quicktile...'
# Generate configuration file, create a backup and overwrite
# with the one from the customization repo
config_file="$HOME"/.config/quicktile.cfg
if [ ! -f "$config_file" ]; then
    quicktile --daemonize &
    mv "$config_file" "$HOME"/.config/quicktile.cfg_bk0
fi
cp "${config_dir}"/quicktile/quicktile.cfg "$config_file"

# Start quicktile
quicktile --daemonize &
# quicktile &

check_exit_status
####################
# Customize panels #
####################
msg 'Customizing panels...'
backup_file="${config_dir}"/Mate_DE/panel/mate-panel-debian-default-backup.dconf
if [ ! -f "$backup_file" ]; then
    # Backup default configuration
     dconf dump /org/mate/panel/ > "$backup_file"
fi

# Replace configuration with custom one
 dconf load /org/mate/panel/ < "${config_dir}"/Mate_DE/panel/mate-panel-debian-custom.dconf

check_exit_status

###############
# Start plank #
###############
# msg 'Starting Plank...'
# plank &
