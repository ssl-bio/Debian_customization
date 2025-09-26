#!/bin/bash
# 10_user_PostReboot_Miniconda_and_shell_setup.sh
# Description: Script to customize the shell configuration file
# It also configures miniconda installation and shell aspect

# Execution: It should be run after setting zsh as the login shell.
# > ./10_user_PostReboot_Miniconda_and_shell_setup.sh

##################
# Load functions #
##################
source Helper_functions.sh

#################################################
# Define download and customization directories #
#################################################
# Customization directory
script_dir=$(pwd)
cd ..
custom_dir=$(pwd)
config_dir=${custom_dir}/Configuration_files

#######################
# Configure miniconda #
#######################
msg 'Miniconda' 'Configure'
miniconda_dir="$HOME/.local/bin/miniconda3"
"${miniconda_dir}"/condabin/conda init "$(echo $SHELL | awk -F/ '{print $NF}')"
eval "$($miniconda_dir/bin/conda shell.$(basename $SHELL) hook)"

# Configure repos
conda config --add channels bioconda
conda config --add channels conda-forge

# Update
conda update -n base -c conda-forge conda -y

# Install default packages for formating code
pip install black jedi autopep8 flake8 ipython importmagic yapf

# Install minted [LaTeX]
pip install latexminted

check_exit_status "${script_dir}/${log_file}"

##################
# Setup starship #
##################
msg 'Shell and Starship' 'Configure'

# Add configuration
# starship init zsh >> ~/.zshrc

# Restore starship configuration
cp "${config_dir}"/shell/starship.toml $HOME/.config/

# Prevent showing base in the prompt
conda config --set changeps1 False

check_exit_status "${script_dir}/${log_file}"


##########################
# Include Zotero in path #
##########################
# Include zotero dir into path
ishell=$(basename $SHELL)
echo '
# Zotero path
export PATH="$HOME/.local/bin/Zotero_linux-x86_64:$PATH"' |\
    tee -a "$HOME"/."${ishell}"rc
