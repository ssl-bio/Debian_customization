#!/bin/bash
# 05_sudo_Dependencies_and_Fourth_program_batch.sh
# Description: Script to install a fourth batch of programs, including
# Starship (shell prompt), Joplin (Note/todo app),
# Serial cloner (DNA sequences manger), Swach (Color tool)
# Dependencies for Yazi (file manager for cli)
# Note, Yazi is installed in the next script.

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo 05_sudo_Dependencies_and_Fourth_program_batch.sh

##################
# Load functions #
##################
source Helper_functions.sh

########################
# Get user directories #
########################
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
user_name=$(logname)

#######################
# Define download dir #
#######################
get_user_dir XDG_DOWNLOAD_DIR idownload "${user_home}"
installation_dl_dir="${idownload}/${download_dir}"
dir_exist "$installation_dl_dir"

# Script directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

#####################################
# Install Starship Zshell framework #
#####################################
msg 'Starship'
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin
fi
check_exit_status "${script_dir}/${log_file}"

##########
# Joplin #
##########
msg 'Joplin'
cd "$installation_dl_dir" || exit

# Get deb package from gitlab: https://gitlab.com/LFd3v/joplin-desktop-linux-package/-/releases
joplin_url="https://gitlab.com/api/v4/projects/51036930/packages/generic/joplin-desktop-linux-package/3.4.11/joplin_3.4.11_amd64.deb"
if [ ! -f Joplin.deb ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$joplin_url" -O "$installation_dl_dir"/Joplin.deb
fi

# Install
if ! dpkg -l | grep -q joplin; then
    dpkg --force-confdef -i "$installation_dl_dir"/Joplin.deb
fi

check_exit_status "${script_dir}/${log_file}"

#####################
# Superproductivity #
#####################
# msg 'Superproductivity'
# # Get deb package from gitlab: https://github.com/johannesjo/super-productivity/releases
# super_url="https://github.com/johannesjo/super-productivity/releases/download/v11.1.3/superProductivity-amd64.deb"
# cd "$installation_dl_dir" || exit
# if [ ! -f Super_productivity.deb ]; then
#     wget --tries=2 --retry-connrefused --waitretry=10 "$super_url" -O "$installation_dl_dir"/Super_Productivity.deb
# fi

# # Install
# if ! dpkg -l | grep -q superproductivity; then
#     dpkg --force-confdef -i "$installation_dl_dir"/Super_Productivity.deb
# fi

# check_exit_status "${script_dir}/${log_file}"

#################
# Serial Cloner #
#################
msg 'Serial Cloner'
# Add 32-bit architecture
sudo dpkg --add-architecture i386
sudo apt update

# Install dependencies
apt install libc6:i386 libstdc++6:i386 \
    libgtk2.0-0:i386 libglib2.0-0:i386 \
    libgdk-pixbuf-2.0-0:i386 libpango-1.0-0:i386 \
    libpangocairo-1.0-0:i386 libpangoft2-1.0-0:i386 \
    libxi6:i386 libxext6:i386 libx11-6:i386 \
    libcairo2:i386 -qy

# Download and extract the tar file
serial_url="http://serialbasics.free.fr/Serial_Cloner-Download_files/SerialCloner2-6.tar"
cd "$installation_dl_dir" || exit
if [ ! -f SerialCloner2-6.tar ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$serial_url"
fi
tar -xf SerialCloner2-6.tar -C "$local_bin"

# Add launcher
ilauncher="$user_home/.local/share/applications/serial_cloner.desktop"
sudo -u "$user_name" touch "$ilauncher"
# sudo chmod 755 "$ilauncher"

echo -e "[Desktop Entry]
      Name=Serial Cloner 2.6
      Exec=~/.local/bin/SerialCloner2-6/SerialCloner2.6.1
      Type=Application
      Categories=Education;
      Comment=Cloning software for managing, designing, and analyzing DNA sequences." | sudo -u "$user_name" tee "$ilauncher"
sed -i 's/^[ \t]*//' "$ilauncher"
check_exit_status "${script_dir}/${log_file}"

########
# Yazi #
########
msg 'Yazi dependencies'
# Install dependencies
apt install file ffmpegthumbnailer unar jq poppler-utils fd-find fzf zoxide ripgrep xclip -qy
check_exit_status "${script_dir}/${log_file}"

#########
# Swach #
#########
cd "$installation_dl_dir" || exit

# Get deb package from the Official page:
# https://www.swach.io/download/linux/
swach_url="https://download.swach.io/download/deb/"
if [ ! -f Swach.deb ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$swach_url" -O "$installation_dl_dir"/Swach.deb
fi 

# Install
if ! dpkg -l | grep -q swach; then
    dpkg --force-confdef -i "$installation_dl_dir"/Swach.deb
fi
