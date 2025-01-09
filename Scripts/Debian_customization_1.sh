#!/bin/bash
# Debian_customization.sh
# Description: Script to customize a basic Debian installation through the addition
# of repositories, the customization of panels, keyboard shortcuts and the
# installation of a number of programs.

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo Debian_customization.sh

##################
# Load functions #
##################
source Helper_functions.sh

#################
# Get user home #
#################
user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
user_name=$(logname)

###########################################
# Define download and script directories #
###########################################
idownload="$user_home/Download_installation"
if [ ! -d "$idownload" ]; then 
    mkdir -p "$idownload"
    chown "$user_name:$user_name" "$idownload"
fi

# Script directory
script_dir=$(pwd)

#################
# Add backports #
#################
# Check if backports had been enabled
ifile='/etc/apt/sources.list.d/backports.list'
if [ ! $ifile ]; then
    msg 'Adding backports...'
    touch ${ifile}
    echo 'deb http://deb.debian.org/debian bookworm-backports main' |
        tee ${ifile}
else
    if ! grep -q "bookworm-backports" "$ifile"; then
	msg 'Adding backports...'
	echo 'deb http://deb.debian.org/debian bookworm-backports main' |
            tee -a ${ifile}
    else
	msg 'Backports were enabled already'
    fi
fi
apt update

# Install emacs from backports to ensure it is 29>
apt install -t bookworm-backports emacs -qy

check_exit_status

###################################
# Install first batch of programs #
###################################
msg 'Installing the first batch of programs...'
apt install git build-essential cmake curl rsync seahorse clamav clamtk tilix fzf zoxide ufw gufw dconf-cli dconf-editor plank compiz-mate emerald -qy

check_exit_status

#######################
# Expand repositories #
#######################
msg 'Expanding repositories...'
# Create a copy of the sources.list and add the contrib source
if [ ! -f /etc/apt/sources.list.bak ]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi
sed -i '/^deb/{/debian\.org/{/ contrib /!s/ main / main contrib /}}' /etc/apt/sources.list

check_exit_status

######################
# Add deb-multimedia #
######################
deb_multimedia_url="https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb"
isources="/etc/apt/sources.list"

# Check if deb multimedia has been installed already
if ! grep -q "deb-multimedia.org" "$isources"; then
    msg 'Adding deb-multimedia repository...'
    wget --tries=2 --retry-connrefused --waitretry=10 "$deb_multimedia_url" -O "$idownload"/deb-multimedia.deb
    dpkg -i "$idownload"/deb-multimedia.deb
    echo "
# Deb multimedia
deb https://www.deb-multimedia.org bookworm main non-free" |\
	tee -a "$isources"
    apt update && DEBIAN_FRONTEND=noninteractive apt dist-upgrade -qy
else
    msg 'deb-multimedia repository was already added'
fi
check_exit_status

#####################################################
# Add configuration for fzf and zoxide to =.bashrc= #
#####################################################
ibashrc="$user_home"/.bashrc
# Backup .bashrc
if [ ! -f "$user_home"/.bashrc.bak ]; then 
    sudo -u "$user_name" cp "$ibashrc" "$user_home"/.bashrc.bak
fi

# Add fzf and zoxide configuration
if ! grep -q "zoxide" "$ibashrc"; then
    msg 'Adding configuration for fzf and zoxide to =.bashrc=...'
    echo '
# fzf shortcuts
source /usr/share/doc/fzf/examples/key-bindings.bash

# zoxide
eval "$(zoxide init bash)"' >> "$ibashrc"
    sed -i 's/^[ \t]*//' "$ibashrc"
else
    msg 'Zoxide and fzf were already configured in =.bashrc='
fi

check_exit_status

#############################################
# Clone repository with configuration files #
#############################################
msg 'Cloning repository with configuration files...'
# Define variable for this directory
custom_dir="$user_home"/Debian_customization
config_dir=${custom_dir}/Configuration_files

# git clone debian_customization
if [ ! -d "$custom_dir" ]; then
    msg 'Clonig repo...'
    # git clone "$custom_dir"
fi
chown -R "$user_name:$user_name" "$custom_dir"

check_exit_status

#################
# Configure ufw #
#################
msg 'Configuring ufw...'
ufw enable

blocked_ports=("53" "135" "137:139" "161" "389" "445")
protocols=("udp" "tcp")
for iport in "${blocked_ports[@]}"; do
    for iproto in "${protocols[@]}"; do
	ufw deny proto "$iproto" to any port "$iport"
    done
done

blocked_ports=("20" "21" "22" "23" "25" "69" "3389" "5900:5902" "512:514" "873" "111" "2049" "110" "143" "80" "8000" "8080" "8888" "1433" "1521" "3306" "5000" "5432" "6379" "27017:27018")
for iport in "${blocked_ports[@]}"; do
    ufw deny proto tcp to any port "$iport"
done

check_exit_status

####################################
# Add NerdFontsSymbols system-wide #
####################################
msg 'Installing NerdFontsSymbols...'
# Check: https://github.com/ryanoasis/nerd-fonts/releases
nerd_url='https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/NerdFontsSymbolsOnly.tar.xz'
font_dir="/usr/share/fonts/truetype"
cd "$idownload" || exit
if [ ! -f NerdFontsSymbolsOnly.tar.xz ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$nerd_url"
fi
mkdir SymbolsNerdFont
tar -xf NerdFontsSymbolsOnly.tar.xz -C "SymbolsNerdFont"
mv SymbolsNerdFont "$font_dir"

# Rebuild font cache
fc-cache -f -v

check_exit_status

###############
# Setup Emacs #
###############
if [ -d "$user_home"/.emacs.d/ ]; then
    cd "$user_home"/.emacs.d/ || exit
    # Test if the repo has been cloned already
    if ! git branch --list "straight_no_helm" > /dev/null 2>&1; then
	msg 'Setting up Emacs...'
        # Backup directory
        cd ..
        mv "$user_home"/.emacs.d/ "$user_home"/.emacs.d_bk0
    fi
fi
# Clone the configuration file and check the no_helm branch
sudo -u "$user_name" git clone https://github.com/ssl-bio/emacs_conf.git "$user_home"/.emacs.d
cd "$user_home"/.emacs.d/ || exit
sudo -u "$user_name" git checkout straight_no_helm
cd ..

check_exit_status

#####################
# Install Quicktile #
#####################
# msg 'Installing Quicktile dependencies...'
# Dependencies
apt install python3 python3-pip python3-setuptools python3-gi python3-xlib python3-dbus gir1.2-glib-2.0 gir1.2-gtk-3.0 gir1.2-wnck-3.0 -qy

if [ ! -d "$idownload"/quicktile ]; then
    msg 'Installing Quicktile...'
    git clone https://github.com/ssokolow/quicktile.git "$idownload"/quicktile
else
    msg 'Quicktile seems to be present already'
fi
cd "$idownload"/quicktile || exit
./install.sh
cd ../..

check_exit_status

###########################
# Install Albert launcher #
###########################
if ! dpkg -l | grep -q albert; then
    msg 'Installing Albert launcher...'
    # Add repository
    echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_12/ /' | tee /etc/apt/sources.list.d/home:manuelschneid3r.list
    sudo -u "$user_name" curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/Debian_12/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null

    # Update and install Albert
    apt update && apt install albert -qy
else
    msg 'Albert was installed before'
fi

# Backup configuration and replace with custom one
if [ -f "$user_home"/.config/albert.conf ] &&
       [ ! -f "$user_home"/.config/albert.conf.bak ]; then
    sudo -u "$user_name" cp "$user_home"/.config/albert.conf "$user_home"/.config/albert.conf.bak
fi

sudo -u "$user_name" cp "${config_dir}"/albert/albert.conf "$user_home"/.config/albert.conf

check_exit_status

###########################################
# Expand the list of startup applications #
###########################################
msg 'Expanding the list of startup applications...'
startup_dir="$user_home"/.config/autostart
rsync -rlptz --chown="${user_name}:${user_name}" "${config_dir}"/Mate_DE/autostart/ "${startup_dir}"/

check_exit_status

#####################
# Configure flatpak #
#####################
msg 'Configuring flatpak...'
apt install flatpak -qy

# Add repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install thunderbird
msg 'Installing Thunderbird...'
flatpak install flathub org.mozilla.Thunderbird -y

check_exit_status
