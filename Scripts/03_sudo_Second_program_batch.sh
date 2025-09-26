#!/bin/bash
# 03_sudo_Second_program_batch.sh
# Description: Script to install a second batch of programs including:
# Dependencies for Emacs and  Miniconda
# R repositories, TeXLive.
# Cloning viewer app (Snapgene),
# CLI interface for cloud storage (Rclone)
# and other packages grouped into categories

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo 03_sudo_Second_program_batch.sh


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

##############################################
# Install dependencies for optional programs #
##############################################
# Emacs-related packages
msg 'Emacs-related packages'
apt install pandoc -qy
check_exit_status "${script_dir}/${log_file}"

# Dependecies for anaconda/R
msg 'Dependecies for anaconda/R'
apt install libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libcurl4-openssl-dev libxml2-dev -qy
check_exit_status "${script_dir}/${log_file}"

# Snapgene viewer
msg 'Snapgene viewer'
apt install ttf-mscorefonts-installer -qy
check_exit_status "${script_dir}/${log_file}"

# Firmware and drivers
msg 'Firmware and drivers'
apt install firmware-linux-nonfree blueman pulseaudio-utils pipewire-audio-client-libraries wireplumber libspa-0.2-bluetooth printer-driver-gutenprint xsane -qy
check_exit_status "${script_dir}/${log_file}"

# Laptop specific
#msg 'Laptop specific libraries'
#apt install firmware-realtek -qy
#check_exit_status "${script_dir}/${log_file}"

####################################
# Install second batch of programs #
####################################
# Version control packages
msg 'Version control packages'
apt install gitg meld git-lfs -qy
check_exit_status "${script_dir}/${log_file}"

# Peripherals / Scanning / Input
msg 'Input packages'
apt install ibus -qy
check_exit_status "${script_dir}/${log_file}"

# System Monitoring / Utilities
msg 'System Utilities packages'
apt install htop tree bsdmainutils gparted keepassxc bat -qy
check_exit_status "${script_dir}/${log_file}"

# Mate Desktop Environment
msg 'Mate Desktop Environment'
apt install mate-desktop-environment-extra caja-open-terminal mozo -qy
check_exit_status "${script_dir}/${log_file}"

# Multimedia
msg 'Multimedia packages'
apt install audacity sayonara vlc obs-studio openshot-qt puddletag cuetools shntool -qy
check_exit_status "${script_dir}/${log_file}"

# Graphics / Design
msg 'Graphics packages'
apt install inkscape gimp -qy
check_exit_status "${script_dir}/${log_file}"

# Document Management
msg 'Document Management packages'
apt install calibre pdftk tesseract-ocr pdfarranger krop -qy
check_exit_status "${script_dir}/${log_file}"

# File Sharing / Synchronization
msg 'Sharing/Sync packages'
apt install transmission -qy
check_exit_status "${script_dir}/${log_file}"

# Development Tools
msg 'Dev Tools packages'
apt install libhandy-1-dev sqlitebrowser -qy
check_exit_status "${script_dir}/${log_file}"

# Bioinformatics / Mol bio
msg 'Mol bio packages'
apt install perlprimer -qy
check_exit_status "${script_dir}/${log_file}"

# Other / Miscellaneous
msg 'Other packages'
apt install goldendict redshift chromium thunderbird -qy
check_exit_status "${script_dir}/${log_file}"

################################
# Install and configure Rclone #
################################
msg 'Rclone'
# Check https://rclone.org/downloads/ for the latest version
rclone_url="https://downloads.rclone.org/v1.71.0/rclone-v1.71.0-linux-amd64.deb"
cd "$installation_dl_dir" || exit
if [ ! -f rclone.deb ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 ${rclone_url} -O "$installation_dl_dir"/rclone.deb
fi

if ! dpkg -l | grep -q rclone; then
    dpkg --force-confdef -i "$installation_dl_dir"/rclone.deb
fi

check_exit_status "${script_dir}/${log_file}"

################
# Install Hugo #
################
# msg 'Hugo'
# # Check https://github.com/gohugoio/hugo/releases/latest for the latest release
# hugo_url="https://github.com/gohugoio/hugo/releases/download/v0.150.0/hugo_extended_withdeploy_0.150.0_linux-arm64.deb"
# cd "$installation_dl_dir" || exit
# if [ ! -f hugo.deb ];then
#     wget --tries=2 --retry-connrefused --waitretry=10 "${hugo_url}" -O "$installation_dl_dir"/hugo.deb    
# fi

# # Install
# if ! dpkg -l | grep -q hugo; then
#     dpkg --force-confdef -i "$installation_dl_dir"/hugo.deb
# fi

# check_exit_status "${script_dir}/${log_file}"

###########################
# Install and configure R #
###########################
msg 'R' 'Installing and configuring'
# Instructions
# https://cran.r-project.org/bin/linux/ubuntu/fullREADME.html

# Get the key
rkey='95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
gpg --keyserver keyserver.ubuntu.com \
    --recv-key "${rkey}"

# export key
gpg --armor --export "${rkey}" | \
    tee /etc/apt/trusted.gpg.d/cran_debian_key.asc

# Add source to sources.list
isources="/etc/apt/sources.list"
if ! grep -q "cloud.r-project.org" "$isources"; then
    echo -e "\n#R (CRAN)\ndeb https://cloud.r-project.org/bin/linux/debian "$deb_ver"-cran40/" |\
	tee -a "$isources"
fi
# Install dependencies
apt install libssl-dev # Tidyverse

# Install R
apt update
apt install r-base r-base-dev -qy

# Install Bioconductor
cd "$script_dir" || exit
Rscript Bioconductor.R

# Install packages for formating code
sudo -u "$user_name" Rscript -e "dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE); install.packages(c('lintr', 'styler'), repos='https://cran.rstudio.com/', lib=Sys.getenv('R_LIBS_USER'), quiet=TRUE)"

check_exit_status "${script_dir}/${log_file}"

#################################
# Install and configure TeXLive #
#################################
msg 'TeXLive'
# Install dependencies
apt install perl-tk tk tex-common texinfo lmodern -qy

# Set up variables
# custom_dir="${user_home}/Linux_customization"
# config_dir=${custom_dir}/Configuration_files
# iso_dir=${custom_dir}/Aux_files
profile_file="${config_dir}/TeXLive/texlive_basic.profile"
install_dir="/usr/local/texlive"
extract_dir="texlive"
tex_ver=2025

# Mount iso file and cp list of packages
tex_url="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
cd "$installation_dl_dir" || exit
if [ ! -f install-tl-unx.tar.gz ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "${tex_url}" -O TeXLive.tar.gz
fi

dir_exist $extract_dir
tar -xzf TeXLive.tar.gz -C $extract_dir --strip-components=1

cd "$extract_dir" || exit
  
# Installation with script
perl install-tl --profile="$profile_file"

# Create symlinks
ln -s "${install_dir}"/"${tex_ver}"/bin/x86_64-linux/* /usr/local/bin/
ln -s "${install_dir}"/"${tex_ver}"/texmf-dist/doc/man /usr/local/man
ln -s "${install_dir}"/"${tex_ver}"/texmf-dist/doc/info /usr/local/info

# Backup installation and link to shared location 
# mv /usr/local/texlive /usr/local/texlive_bk0
# ln -s /media/discs/shared/texlive /usr/local/texlive

# Install custom packages
# eval tlmgr -repository "$installer_dir" install $(<installed-packages)

# Update font database
# texlive_font="/etc/fonts/conf.d/09-texlive.conf"
# if [ -f "$texlive_font" ]; then
#     rm "$texlive_font"
# fi
# ln -s /usr/local/texlive/"${tex_ver}"/texmf-var/fonts/conf/texlive-fontconfig.conf "$texlive_font"
# fc-cache -fsv

check_exit_status "${script_dir}/${log_file}"
