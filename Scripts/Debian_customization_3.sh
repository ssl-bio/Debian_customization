#!/bin/bash
# Debian_customization_3.sh
# Description: Script to customize a basic Debian installation through the addition
# of repositories, the customization of panels, keyboard shortcuts and the
# installation of a number of programs.

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo Debian_customization_3.sh

##################
# Load functions #
##################
source Helper_functions.sh

########################
# Get user directories #
########################
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
user_name=$(logname)
idownload="$user_home/Download_installation"
if [ ! -d "$idownload" ]; then 
    mkdir -p "$idownload"
    chown "$user_name:$user_name" "$idownload"
fi
local_bin="$user_home"/.local/bin
if [ ! -d "$local_bin" ]; then 
    mkdir -p "$local_bin"
    chown "$user_name:$user_name" "$local_bin"
fi

##########
# Joplin #
##########
msg 'Installing Joplin...'
cd "$idownload" || exit

# Get deb package from gitlab: https://gitlab.com/LFd3v/joplin-desktop-linux-package/-/releases
joplin_url="https://gitlab.com/api/v4/projects/51036930/packages/generic/joplin-desktop-linux-package/3.1.24/joplin_3.1.24_amd64.deb"
if [ ! -f Joplin.deb ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$joplin_url" -O "$idownload"/Joplin.deb
fi

# Install
if ! dpkg -l | grep -q joplin; then
    dpkg --force-confdef -i "$idownload"/Joplin.deb
fi

check_exit_status

#####################
# Superproductivity #
#####################
msg 'Installing Superproductivity...'
# Get deb package from gitlab: https://github.com/johannesjo/super-productivity/releases
super_url="https://github.com/johannesjo/super-productivity/releases/download/v11.0.3/superProductivity-amd64.deb"
cd "$idownload" || exit
if [ ! -f Super_productivity.deb ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$super_url" -O "$idownload"/Super_Productivity.deb
fi

# Install
if ! dpkg -l | grep -q superproductivity; then
    dpkg --force-confdef -i "$idownload"/Super_Productivity.deb
fi

check_exit_status

#################
# Serial Cloner #
#################
msg 'Installing Serial Cloner...'
# Download and extract the tar file
serial_url="http://serialbasics.free.fr/Serial_Cloner-Download_files/SerialCloner2-6.tar"
cd "$idownload" || exit
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
check_exit_status

########
# Yazi #
########
msg 'Installing Yazi dependencies...'
# Install dependencies
apt install file ffmpegthumbnailer unar jq poppler-utils fd-find fzf zoxide ripgrep -qy
