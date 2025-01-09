#!/bin/bash
# Debian_customization_2.sh
# Description: Script to further customize a basic Debian installation through
# the installation of additional programs

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo Debian_customization_2.sh


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
idownload="$user_home/Download_installation"
if [ ! -d "$idownload" ]; then 
    mkdir -p "$idownload"
    chown "$user_name:$user_name" "$idownload"
fi

# Check if ~/.local/bin/ exists
local_bin="$user_home"/.local/bin
if [ ! -d "$local_bin" ]; then 
    mkdir -p "$local_bin"
    chown "$user_name:$user_name" "$local_bin"
fi

# Script directory
script_dir=$(pwd)

######################################
# Load custom functions from .bashrc #
######################################
# msg 'Loading custom functions...'
# custom_dir="$user_home/Debian_customization/Configuration_files"

# # Create a backup
if [ ! -f "$user_home"/.bashrc.bak ]; then 
    sudo -u "$user_name" cp "$user_home"/.bashrc "$user_home"/.bashrc.bak
fi
# # Add code to load custom functions (if present)
# echo '
#     # Import custom functions
#         if [ -f ~/.bash_functions ]; then
#             . ~/.bash_functions
#         fi'

# # Copy file with custom funtions and reload
# sudo -u "$user_name" cp "${config_dir}"/bash/.bash_functions "$user_home"/.bash_functions
# sudo -u "$user_name" bash -c "source $user_home/.bashrc"

##############################################
# Install dependencies for optional programs #
##############################################
msg 'Installing dependencies for optional programs...'
# Emacs-related
apt install pandoc -qy

# Dependecies for anaconda/R
apt install libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libcurl4-openssl-dev libxml2-dev -qy

# Snapgene viewer
apt install ttf-mscorefonts-installer -qy

#Firmware and drivers
apt install firmware-linux-nonfree blueman printer-driver-gutenprint xsane -qy

# Laptop specific
# apt install firmware-realtek -qy

check_exit_status

####################################
# Install second batch of programs #
####################################
msg 'Installing second batch of programs...'
# Version control
apt install git-lfs -qy

# Peripherals / Scanning / Input
apt install ibus -qy

# System Monitoring / Utilities
apt install htop tree bsdmainutils gparted keepassxc -qy

# Macchanger needs user input
# apt install macchanger -y

# Mate Desktop Environment
apt install mate-dock-applet mate-desktop-environment-extra caja-open-terminal mozo -qy

# Multimedia
apt install audacity sayonara vlc obs-studio openshot-qt puddletag cuetools -qy

# Graphics / Design
apt install inkscape gimp -qy

# Document Management
apt install calibre pdftk tesseract-ocr pdfarranger krop -qy

# File Sharing / Synchronization
apt install transmission -y

# Development Tools
apt install meld libhandy-1-dev sqlitebrowser -y

# Other / Miscellaneous
apt install goldendict redshift -qy

check_exit_status

################################
# Install and configure Rclone #
################################
msg 'Installing and configure Rclone...'
# Check https://rclone.org/downloads/ for the latest version
rclone_url="https://downloads.rclone.org/v1.68.2/rclone-v1.68.2-linux-amd64.deb"
cd "$idownload" || exit
if [ ! -f rclone.deb ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 ${rclone_url} -O "$idownload"/rclone.deb
fi

if ! dpkg -l | grep -q rclone; then
    dpkg --force-confdef -i "$idownload"/rclone.deb
fi

check_exit_status

################
# Install Hugo #
################
msg 'Installing Hugo...'
# Check https://github.com/gohugoio/hugo/releases/latest for the latest release
hugo_url="https://github.com/gohugoio/hugo/releases/download/v0.140.0/hugo_extended_0.140.0_linux-amd64.deb"
cd "$idownload" || exit
if [ ! -f hugo.deb ];then
    wget --tries=2 --retry-connrefused --waitretry=10 "${hugo_url}" -O "$idownload"/hugo.deb    
fi

# Install
if ! dpkg -l | grep -q hugo; then
    dpkg --force-confdef -i "$idownload"/hugo.deb
fi

check_exit_status

###########################
# Install and configure R #
###########################
msg 'Installing and configuring R...'
# Get the key
gpg --keyserver keyserver.ubuntu.com \
    --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'

# export key
gpg --armor --export '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' | \
    tee /etc/apt/trusted.gpg.d/cran_debian_key.asc

# Add source to sources.list
isources="/etc/apt/sources.list"
if ! grep -q "cloud.r-project.org" "$isources"; then
    echo -e '\n#R (CRAN)\ndeb http://cloud.r-project.org/bin/linux/debian bookworm-cran40/' |\
	tee -a "$isources"
fi

# Install R
apt update
apt install r-base r-base-dev -qy

# Install Bioconductor
cd "$script_dir" || exit
Rscript Bioconductor.R

# Install packages for formating code
sudo -u "$user_name" Rscript -e "dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE); install.packages(c('lintr', 'styler'), repos='https://cran.rstudio.com/', lib=Sys.getenv('R_LIBS_USER'), quiet=TRUE)"

check_exit_status

#################################
# Install and configure TeXLive #
#################################
msg 'Installing and configuring TeXLive...'
# Install dependencies
sudo apt install perl-tk tk tex-common texinfo lmodern -qy

# Set up variables
custom_dir="${user_home}/Debian_customization"
config_dir=${custom_dir}/Configuration_files
# profile_file="${config_dir}/TeXLive/texlive_basic_auto.profile"
profile_file="${config_dir}/TeXLive/texlive_medium_auto.profile"
# package_dir="${config_dir}/TeXLive/"
texlive_url="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
install_dir="/usr/local/texlive"

# Download installer
cd "$idownload" || exit
if [ ! -f install-tl-unx.tar.gz ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 $texlive_url -O "$idownload"/install-tl-unx.tar.gz
fi
mkdir temp_dir
tar -xvzf "$idownload"/install-tl-unx.tar.gz -C temp_dir
mv temp_dir/install-tl-* "$idownload"/texlive_installer
rm -rf temp_dir
cd "$idownload"/texlive_installer || exit

# Installation with script
perl install-tl --profile="$profile_file"

# Create symlinks
ln -s "${install_dir}"/2024/bin/x86_64-linux/* /usr/local/bin/
ln -s "${install_dir}"/2024/texmf-dist/doc/man /usr/local/man
ln -s "${install_dir}"/2024/texmf-dist/doc/info /usr/local/info

# Update font database
texlive_font="/etc/fonts/conf.d/09-texlive.conf"
if [ -f "$texlive_font" ]; then
    rm "$texlive_font"
fi
ln -s /usr/local/texlive/2024/texmf-var/fonts/conf/texlive-fontconfig.conf "$texlive_font"
fc-cache -fsv

check_exit_status

######################
# Install Virtualbox #
######################
msg 'Installing Virtualbox...'
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

check_exit_status
