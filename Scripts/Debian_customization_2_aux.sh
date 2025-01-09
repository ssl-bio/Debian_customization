#!/bin/bash
# Debian_customization_2_aux.sh
# Description: Accompanying script for Debian_customization_2.sh used to
# setup Compiz, Tilix, and Quicktile as a regular user

# Execution: If ran separately it needs to be run as a regular user
# > Debian_customization_2_aux.sh

##################
# Load functions #
##################
source Helper_functions.sh


########################
# Set user directories #
########################
# Download directory
idownload="$HOME"/Download_installation
if [ ! -d "$idownload" ]; then 
    mkdir -p "$idownload"
fi

# Local bin
local_bin="$HOME"/.local/bin
if [ ! -d "$local_bin" ]; then 
    mkdir -p "$local_bin"
fi

################################
# Install and configure Zotero #
################################
msg 'Installing and configure Zotero...'
# Download Zotero
# Check https://www.zotero.org/download/ for the latest version
zotero_url="https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=7.0.11"

cd "$idownload" || exit
if [ ! -f Zotero.tar.bz2 ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "${zotero_url}" -O "$idownload"/Zotero.tar.bz2
fi

# Extract files to ~/.local/bin
tar -xf "$idownload"/Zotero.tar.bz2 -C "${local_bin}"

# Add launcher to menu
"${local_bin}"/Zotero_linux-x86_64/./set_launcher_icon
ln -s "${local_bin}"/Zotero_linux-x86_64/zotero.desktop "$HOME"/.local/share/applications/zotero.desktop

# Include zotero dir into path
echo '
export PATH="$HOME/.local/bin/Zotero_linux-x86_64:$PATH"' |\
    tee -a "$HOME"/.bashrc

check_exit_status

###############
# Install tor #
###############
msg 'Installing Tor...'
# Check https://www.torproject.org/download/ for the latest installation file
tor_url="https://www.torproject.org/dist/torbrowser/14.0.3/tor-browser-linux-x86_64-14.0.3.tar.xz"
cd "$idownload" || exit
if [ ! -f Tor_linux.tar.xz ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 ${tor_url} -O "$idownload"/Tor_linux.tar.xz
fi

tar -xf "$idownload"/Tor_linux.tar.xz -C "${local_bin}"

# Register app
cd "${local_bin}"/tor-browser || exit
./start-tor-browser.desktop --register-app

################################
# Install Miniconda (Anaconda) #
################################
msg 'Installing Miniconda...'

miniconda_dir="$HOME/.local/bin/miniconda3"
miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
cd "$idownload" || exit
if [ ! -f Miniconda3-latest-Linux-x86_64.sh ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$miniconda_url"
fi
bash Miniconda3-latest-Linux-x86_64.sh -b -p "${miniconda_dir}"

# Add initialization code to bashrc and reload
"${miniconda_dir}"/condabin/conda init "$(echo $SHELL | awk -F/ '{print $NF}')"
eval "$($miniconda_dir/bin/conda shell.bash hook)"

# Configure repos
conda config --add channels bioconda
conda config --add channels conda-forge

# Update
conda update -n base -c conda-forge conda -y

# Install default packages for formating code
pip3 install black jedi autopep8 flake8 ipython importmagic yapf

check_exit_status
