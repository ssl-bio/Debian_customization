#!/bin/bash
# 04_user_Configuration_and_Third_program_batch.sh
# Description: Script to configure R library path and
# install: Reference manager (Zotero), Private Web Browser (Tor), 
# Anaconda distribution (Miniconda).

# Execution: If ran separately it needs to be run as a regular user
# > ./04_user_Configuration_and_Third_program_batch.sh

##################
# Load functions #
##################
source Helper_functions.sh

########################
# Set user directories #
########################
# Download directory
get_user_dir XDG_DOWNLOAD_DIR idownload
installation_dl_dir="${idownload}/${download_dir}"
dir_exist "$installation_dl_dir"
dir_exist "$local_bin"

# Script directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

###############
# Configure R #
###############
# Setup directory for local files
r_env_file="$HOME"/.Renviron
rpath='R_LIBS_USER=${HOME}/.local/R/%p-library/%v'
if [ ! "$r_env_file" ]; then
    touch "$r_env_file"
    echo $rpath | tee "$r_env_file"
else
    if ! grep -q "R_LIBS_USER" "$r_env_file"; then
	echo $rpath | tee -a "$r_env_file"
    fi
fi

# Install packages for formating code
Rscript -e "dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE); install.packages(c('lintr', 'styler'), repos='https://cran.rstudio.com/', lib=Sys.getenv('R_LIBS_USER'), quiet=TRUE)"

################################
# Install and configure Zotero #
################################
msg 'Zotero'
# Download Zotero
# Check https://www.zotero.org/download/ for the latest version
zotero_url="https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64"

cd "$installation_dl_dir" || exit
if [ ! -f Zotero.tar.bz2 ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "${zotero_url}" -O "$installation_dl_dir"/Zotero.tar.bz2
fi

# Extract files to ~/.local/bin
tar -xf "$installation_dl_dir"/Zotero.tar.bz2 -C "${local_bin}"

# Add launcher to menu
"${local_bin}"/Zotero_linux-x86_64/./set_launcher_icon
ln -s "${local_bin}"/Zotero_linux-x86_64/zotero.desktop "$HOME"/.local/share/applications/zotero.desktop

check_exit_status "${script_dir}/${log_file}"

###############
# Install tor #
###############
msg 'Tor'
# Check https://www.torproject.org/download/ for the latest installation file
tor_url="https://www.torproject.org/dist/torbrowser/14.5.7/tor-browser-linux-x86_64-14.5.7.tar.xz"
cd "$installation_dl_dir" || exit
if [ ! -f Tor_linux.tar.xz ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 ${tor_url} -O "$installation_dl_dir"/Tor_linux.tar.xz
fi

tar -xf "$installation_dl_dir"/Tor_linux.tar.xz -C "${local_bin}"

# Register app
cd "${local_bin}"/tor-browser || exit
./start-tor-browser.desktop --register-app

################################
# Install Miniconda (Anaconda) #
################################
msg 'Miniconda'

miniconda_dir="$HOME/.local/bin/miniconda3"
miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
cd "$installation_dl_dir" || exit
if [ ! -f Miniconda3-latest-Linux-x86_64.sh ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$miniconda_url"
fi
bash Miniconda3-latest-Linux-x86_64.sh -b -p "${miniconda_dir}"
check_exit_status "${script_dir}/${log_file}"
