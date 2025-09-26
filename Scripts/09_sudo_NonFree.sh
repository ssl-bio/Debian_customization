#!/bin/bash
# 09_sudo_NonFree.sh
# Description: Script to install non-free programs such as:
# VirtualBox and Spotify 

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo 09_sudo_NonFree.sh


##################
# Load functions #
##################
source Helper_functions.sh

#################
# Get user home #
#################
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
user_name=$(logname)

##################################################
# Define download directory and create local/bin #
##################################################
get_user_dir XDG_DOWNLOAD_DIR idownload "${user_home}"
installation_dl_dir="${idownload}/${download_dir}"
dir_exist "$installation_dl_dir"

# Script directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

######################
# Install Virtualbox #
######################
msg 'Virtualbox'
# Import the VirtualBox-signed GPG keys
vbox_key="https://www.virtualbox.org/download/oracle_vbox_2016.asc"
wget --tries=2 --retry-connrefused --waitretry=10 -qO- "$vbox_key" | gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox.gpg

# Change the mod of the key
chmod 644 /usr/share/keyrings/oracle-virtualbox.gpg

# Add the repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | tee /etc/apt/sources.list.d/virtualbox.list

# Change the mod of the key
chmod 644 /etc/apt/sources.list.d/virtualbox.list

# Update repositories
if ! dpkg -l | grep -q virtualbox; then
    apt update && apt install virtualbox-7.1 -qy
fi

# Add user to vboxusers group
usermod -a -G vboxusers "$user_name"

check_exit_status "${script_dir}/${log_file}"

###########
# Spotify #
###########
msg 'Spotify'
spotify_url="https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg"
# Get deb package from gitlab:
curl -sS "$spotify_url" | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
apt update && apt install spotify-client -qy
