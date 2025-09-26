#!/bin/bash
# 01_sudo_Repo_setup_First_program_batch.sh
# Description: Script to customize a basic Debian installation through the addition
# of repositories, and the installation of a number of programs.

# Execution: The script needs to be run as superuser thus, make sure you check its contents before
# > sudo 01_sudo_Repo_setup_First_program_batch.sh

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
get_user_dir XDG_DOWNLOAD_DIR idownload "${user_home}"
installation_dl_dir="${idownload}/${download_dir}"
dir_exist "$installation_dl_dir"
chown ${user_name}:${user_name} "$installation_dl_dir"

# Script directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files


###############################
# Change ownership of logfile #
###############################
chown ${user_name}:${user_name} "${script_dir}/${log_file}"


#################
# Add backports #
#################
# Check if backports had been enabled
ifile='/etc/apt/sources.list.d/backports.list'
if [ ! $ifile ]; then
    msg 'backports' 'Adding'
    touch ${ifile}
    echo "deb http://deb.debian.org/debian ${deb_ver}-backports main" |
        tee ${ifile}
else
    if ! grep -q "${deb_ver}-backports" "$ifile"; then
	msg 'backports' 'Adding'
	echo -e "deb http://deb.debian.org/debian ${deb_ver}-backports main" |
            tee -a ${ifile}
    else
	msg_default 'Backports were enabled already'
    fi
fi
apt update

# Install emacs from backports to ensure it is 29>
apt install -t "$deb_ver"-backports emacs -qy

check_exit_status "${script_dir}/${log_file}"

###################################
# Install first batch of programs #
###################################
msg 'First batch of programs'
apt install git build-essential cmake curl rsync seahorse clamav clamtk tilix gocryptfs trash-cli zsh fzf zoxide ufw gufw dconf-cli dconf-editor plank compiz emerald -qy

check_exit_status "${script_dir}/${log_file}"

#######################
# Expand repositories #
#######################
msg 'repositories' 'Expanding'
# Create a copy of the sources.list and add the contrib source
if [ ! -f /etc/apt/sources.list.bak ]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi
sed -i '/^deb/{/debian\.org/{/ contrib /!s/ main / main contrib /}}' /etc/apt/sources.list

check_exit_status "${script_dir}/${log_file}"

####################################
# Copy Installation files if exist #
####################################
if [ -d ${custom_dir}/Installation_files ]; then
    sudo -u "$user_name" cp -r ${custom_dir}/Installation_files/* ${installation_dl_dir}/
fi


######################
# Add deb-multimedia #
######################
deb_multimedia_url="https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2024.9.1_all.deb"
deb_file="/etc/apt/sources.list.d/dmo.sources"

if [ ! -f "$deb_file" ]; then
    msg 'deb-multimedia' 'Adding'
    wget --tries=2 --retry-connrefused --waitretry=10 "$deb_multimedia_url" -O "$installation_dl_dir"/deb-multimedia.deb
    dpkg -i "$installation_dl_dir"/deb-multimedia.deb
    echo "
Types: deb
URIs: https://www.deb-multimedia.org
Suites: $deb_ver
Components: main non-free
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp
Enabled: yes" > "${deb_file}"
    apt update && DEBIAN_FRONTEND=noninteractive apt dist-upgrade -qy
    check_exit_status "${script_dir}/${log_file}"
else
    msg_default 'deb-multimedia repository was already added'
fi

###################
# Update packages #
###################
apt update && apt upgrade -y

#################################
# Setup Zshell as default shell #
#################################
msg 'Zshell' 'Setting up'

# Change shell
usermod -s "$(which zsh)" ${user_name}

check_exit_status "${script_dir}/${log_file}"

#################
# Configure ufw #
#################
msg 'UFW' 'Configuring'
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

check_exit_status "${script_dir}/${log_file}"

####################################
# Add NerdFontsSymbols system-wide #
####################################
msg 'NerdFontsSymbols'
# Check: https://github.com/ryanoasis/nerd-fonts/releases
# Preview: https://www.nerdfonts.com/font-downloads
nerd_url='https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.tar.xz'
font_dir="/usr/share/fonts/truetype"
cd "$installation_dl_dir" || exit
if [ ! -f NerdFontsSymbolsOnly.tar.xz ]; then
    wget --tries=2 --retry-connrefused --waitretry=10 "$nerd_url"
fi
mkdir SymbolsNerdFont
tar -xf NerdFontsSymbolsOnly.tar.xz -C "SymbolsNerdFont"
mv SymbolsNerdFont "$font_dir"

# Rebuild font cache
fc-cache -f -v

check_exit_status "${script_dir}/${log_file}"

#####################
# Install Quicktile #
#####################
msg 'Quicktile dependencies'
# Dependencies
apt install python3 python3-pip python3-setuptools python3-gi python3-xlib python3-dbus gir1.2-glib-2.0 gir1.2-gtk-3.0 gir1.2-wnck-3.0 -qy
check_exit_status "${script_dir}/${log_file}"

msg 'Quicktile'
sudo -H pip3 install https://github.com/ssokolow/quicktile/archive/master.zip --break-system-packages
cd ../..
check_exit_status "${script_dir}/${log_file}"

###########################
# Install Albert launcher #
###########################
msg 'Albert launcher'
if ! dpkg -l | grep -q albert; then 
    # Add repository
    echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/Debian_13/ /' | tee /etc/apt/sources.list.d/home:manuelschneid3r.list
    sudo -u "$user_name" curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/Debian_13/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null

    # Update and install Albert
    apt update && apt install albert -qy
    check_exit_status "${script_dir}/${log_file}"
else
    msg_default 'Albert was installed before'
fi

# Backup configuration and replace with custom one
if [ -f "$user_home"/.config/albert.conf ] &&
       [ ! -f "$user_home"/.config/albert.conf.bak ]; then
    sudo -u "$user_name" cp "$user_home"/.config/albert.conf "$user_home"/.config/albert.conf.bak
fi

# sudo -u "$user_name" cp "${config_dir}"/albert/albert.conf "$user_home"/.config/albert.conf

check_exit_status "${script_dir}/${log_file}"
