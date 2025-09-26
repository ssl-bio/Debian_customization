#############
# Variables #
#############
deb_ver="trixie" #13
log_file="Installation.log"
local_bin="$HOME"/.local/bin
download_dir="Installation_files"

##############################
# Functions to echo progress #
##############################
msg() {
    export prog="$1"
    export task=${2:-"Installing"}
    msg="${task} ${prog}..."
    inum=${#msg}
    inum=$((inum + 2))

    printf "%0.s-" $(seq 1 "$inum")
    echo -e "\n ${msg}"
    printf "%0.s-" $(seq 1 "$inum")
    echo -e "\n"
}

msg_default() {
    msg="$1"
    inum=${#msg}
    inum=$((inum + 2))

    printf "%0.s-" $(seq 1 "$inum")
    echo -e "\n ${msg}"
    printf "%0.s-" $(seq 1 "$inum")
    echo -e "\n"
    echo "$msg" >> "${log_file}"
}

# Exit status message
check_exit_status() {
    log_path="${1:-$log_file}"
	if [ $? -eq 0 ]; then
	    clear
	    # echo "[o] No errors reported while ${task} ${prog}"
	    echo "- [o] No errors reported while ${task} ${prog}" | tee -a "${log_path}"
	else
	    # echo "[x] Errors reported while ${task} ${prog}"
	    echo "- [x] Errors reported while ${task} ${prog}" | tee -a "${log_path}"
	fi
}

# Get user directory as defined in ~/.config/user-dirs.dirs
get_user_dir() {
	user_dir="$1"
	var_name="$2"
	user_home="${3:-$HOME}"
	# if [[ -z "${!var_name}" ]]; then
	temp=$(grep "^${user_dir}=" ${user_home}/.config/user-dirs.dirs | sed "s/${user_dir}=//g")
	if [[ $# -gt 2 ]]; then
	    temp=$(echo "$temp" | sed "s|\$HOME|$user_home|g")
	fi
	
	resolved_dir="$(eval echo "$temp")"  

	# Dynamically assign the value to the variable name passed as $2
	printf -v "$var_name" "%s" "$resolved_dir"
	# fi
}

# Check if dir exists if not create it
dir_exist() {
	if [ ! -d "$1" ]; then
		mkdir -p "$1"
	fi
}
    
# Check if log file exists if not create it
if [ ! -f "${log_file}" ]; then
    touch "${log_file}"
fi

