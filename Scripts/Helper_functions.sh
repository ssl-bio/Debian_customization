##############################
# Functions to echo progress #
##############################
msg() {
    local msg=$1             
    local inum=${#msg}
    ((inum=inum+2))
    
    printf "%0.s-" $(seq 1 "$inum")
    echo -e "\n ${msg}"
    printf "%0.s-" $(seq 1 "$inum")
    echo -e "\n"
}

# Exit status message
check_exit_status() {
    if [[ $? -eq 0 ]]; then
	clear
	msg "[o] No errors reported"
    else
	msg "[x] Errors reported"
    fi
}

# Get user directory as defined in ~/.config/user-dirs.dirs
get_user_dir() {
    local user_dir="$1"
    local var_name="$2"
    # if [[ -z "${!var_name}" ]]; then
    local temp
    temp=$(grep "^${user_dir}=" ~/.config/user-dirs.dirs | sed "s/${user_dir}=//g")
    local resolved_dir
    resolved_dir="$(eval echo "$temp")"

    # Dynamically assign the value to the variable name passed as $2
    printf -v "$var_name" "%s" "$resolved_dir"
    # fi
}

# Check if dir exists if not create it
dir_exist() {
    if [[ ! -d $1 ]]
    then
	mkdir -p "$1"
    fi
}
