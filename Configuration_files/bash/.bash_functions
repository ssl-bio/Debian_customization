# Image functions
whitebg() {
    #remove transparency in a png and convert it to a jpg
    convert $1 -background white -flatten ${1%.*}.jpg
}

pdf2png() {
    convert -density 300 -depth 8 -quality 85 "$1".pdf "$1".png
}

# Check if dir exists if not create it
dir_exist() {
    if [[ ! -d $1 ]]
    then
	mkdir -p "$1"
    fi
}

# Check if dir exists if not create it (sudo version)
sudo_dir_exist() {
    if [[ ! -d $1 ]]
    then
	sudo mkdir -p "$1"
    fi
}

# Check if dir exists and remove
dir_rm() {
    if [[ -d $1 ]]
    then
	rm -rf "$1"
    fi
}

# Find file
findf() {
    find . -name "${1}*"
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

# Get ANY user directory as defined in ~/.config/user-dirs.dirs
get_users_dir() {
    local user_dir="$1"
    local user_name="$2"
    local var_name="$3"
    local temp
    temp=$(grep "^${user_dir}=" ~/.config/user-dirs.dirs | sed "s/${user_dir}=//g")
    local home_dir
    home_dir=$(echo "$temp" | sed "s|\$HOME|/home/${user_name}|")
    home_dir=$(eval echo $home_dir)
    # Dynamically assign the value to the variable name passed as $2
    printf -v "$var_name" "%s" "$home_dir"
}
