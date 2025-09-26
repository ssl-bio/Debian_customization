#!/bin/bash
# 07_user_Personalization.sh
# Description: Script to restore customizations, including:
# startup applications, panel, terminal emulator (tilix)
# app launcher (Albert), tiling (quicktile), compiz, 
# emacs configuration (through cloning of a Git repo)
# zsh configuration.

# Execution: If ran separately it needs to be run as a regular user
# > ./07_user_Personalization.sh

##################
# Load functions #
##################
source Helper_functions.sh

#################################################
# Define download and customization directories #
#################################################
# Customization directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

################################
# Restore startup applications #
################################
msg 'list of startup applications' 'Expanding'
startup_dir="$HOME"/.config/autostart
dir_exist $startup_dir
rsync -rlptz "${config_dir}"/Mate_DE/autostart/ "${startup_dir}"/

check_exit_status "${script_dir}/${log_file}"

#################################
# Restore Tilix configuration.  #
#################################
# Replace custom settings
# Keybidings
dconf load /com/gexperts/Tilix/keybindings/ < "${config_dir}"/tilix/tilix_custom_keybindings
# Profiles
dconf load /com/gexperts/Tilix/profiles/ < "${config_dir}"/tilix/tilix_custom_profiles

###############
# Setup Emacs #
###############
dir_exist "$HOME"/.emacs.d 
if [ -d "$HOME"/.emacs.d/ ]; then
    cd "$HOME"/.emacs.d/ || exit
    # Test if the repo has been cloned already
    if ! git branch --list "straight_no_helm" > /dev/null 2>&1; then
	msg 'Setting up Emacs...'
        # Backup directory
        cd ..
        mv "$HOME"/.emacs.d/ "$HOME"/.emacs.d_bk0
    fi
fi
# Clone the configuration file and check the no_helm branch
git clone https://github.com/ssl-bio/emacs_conf.git $HOME/.emacs.d --branch straight_no_helm
# cd "$HOME"/.emacs.d/ || exit
# sudo -u "$user_name" git checkout straight_no_helm
# cd ..

check_exit_status "${script_dir}/${log_file}"

###################################
# Restore quicktile configuration #
###################################
msg 'Quicktile' 'Configuring'
# Generate configuration file, create a backup and overwrite
# with the one from the customization repo
config_file="$HOME"/.config/quicktile.cfg
if [ ! -f "$config_file" ]; then
    quicktile --daemonize &
    mv "$config_file" "$HOME"/.config/quicktile.cfg_bk0
fi
cp "${config_dir}"/quicktile/quicktile.cfg "$config_file"
check_exit_status "${script_dir}/${log_file}"

# Start quicktile
quicktile --daemonize &
# quicktile &

check_exit_status "${script_dir}/${log_file}"

################################
# Restore compiz configuration #
################################
msg 'Compiz' 'Setting up'
# Restore profile
source_dir="${config_dir}"/compiz/compizconfig
compiz_dir=$(ls $HOME/.config | grep compiz)
cp -r "${source_dir}" $HOME/.config/${compiz_dir}/compizconfig

# Load Compiz
compiz --replace &

check_exit_status "${script_dir}/${log_file}"

###############################
# Restore panel configuration #
###############################
# Replace configuration with custom one
dconf load /org/mate/panel/ < "${config_dir}"/Mate_DE/panel/mate-panel-debian-custom.dconf

################################
# Restore Albert configuration #
################################
msg 'Albert configuration' 'Restoring'
dir_exist "$HOME"/.config/albert
# Backup configuration and replace with custom one
if [ -f "$HOME"/.config/albert/config ] &&
       [ ! -f "$HOME"/.config/albert/config.bak ]; then
    mv "$HOME"/.config/albert/config "$HOME"/.config/albert/config.bak
fi

cp "${config_dir}"/albert/config "$HOME"/.config/albert/config
check_exit_status "${script_dir}/${log_file}"

###################
# Configure zshrc #
###################
# Create a backup
ishell=$(basename $(which zsh))
if [ -f "$HOME"/."${ishell}"rc ] &&
 [ ! -f "$HOME"/."${ishell}"rc.bak ]; then 
    mv "$HOME"/."${ishell}"rc "$HOME"/."${ishell}"rc.bak
fi

# Restore custom zshrc file
custom_file="${config_dir}"/shell/."${ishell}"rc_basic
if [ -f "$custom_file" ]; then
    cp "$custom_file" "$HOME"/."${ishell}"rc
fi

# Copy custom functions and reload
shell_files=(."${ishell}"_aliases
	     ."${ishell}"_functions)

for ifile in "${shell_files[@]}"; do
    cp "${config_dir}/shell/$ifile" "$HOME"/
done

# Add fzf and zoxide configuration
# if ! grep -q "zoxide" "${ishell}"rc; then
#     msg 'Adding configuration for fzf and zoxide to =.bashrc=...'
#     echo '
# # fzf shortcuts
# source /usr/share/doc/fzf/examples/key-bindings."$ishell"

# # zoxide
# eval "$(zoxide init $ishell)"' >> "${ishell}"rc
#     sed -i 's/^[ \t]*//' "${ishell}"rc
# else
#     msg_default 'Zoxide and fzf were already configured'
# fi

# check_exit_status "${script_dir}/${log_file}"
