# Debian customization notes/scripts

![img](Readme_aux/Desktop.png "Screenshots of customized Debian. Left, Albert application launcher. Right Changing workspaces.")


## Description

Notes and scripts to customize a basic Debian stable (+ Mate Desktop Environment) installation. Briefly, these would expand the default repositories, install a number of programs and customize the window/desktop management.

The list of programs can be divided into several groups (indicated in the name of the files) with only the first one being recommended for the customization and the last 2 being entirely optional and highly subjective.

Customization of the window/desktop management relies on the use of the following programs, *Compiz*, *Quicktile*, *Albert* and *Plank*, as well as, the modification of the default panels. The notes and scripts provide commands to backup the default configuration to facilitate reverting some of all of the changes.


### Notes

Note files are written in Emacs `org-roam` format (an extension of `org-mode`) with `20250107103006-debian_customization.org` being the main file. It provides descriptions and code for all the customization steps. Link to additional notes are provided for some headers. For these to work as intended it is necessary to move them to the `org-roam-directory`. Below is a sample configuration using `straight.el`

```emacs-lisp
(use-package org-roam
  :straight (org-roam :type git
                      :flavor melpa
                      :files (:defaults "extensions/*" "org-roam-pkg.el")
                      :host github
                      :repo "org-roam/org-roam")
  :custom
  (org-roam-directory ~/Documents/Org-files/Org-roam)
  )
```


### Scripts

/ It is recommended to carefully read them to see which software is going to be installed before their execution./

A number of scripts to automate the customization are provided. Despite being highly subjective the scripts are numbered according to their relevance. After the number a string indicates whether the script should be run as a regular- or super-user. A brief description of the script is included in the name and inside each script.

To execute them download the whole repository and execute the scripts from its folder (`$HOME/Debian_customization/Scripts`). Below is a sample code of how to run all of them.

```bash
sudo ./01_sudo_Repo_setup_First_program_batch.sh &&\
./02_user_Backup_configuration.sh &&\
sudo ./03_sudo_Second_program_batch.sh &&\
./04_user_Configuration_and_Third_program_batch.sh &&\
sudo ./05_sudo_Dependencies_and_Fourth_program_batch.sh &&\
./06_user_Yazi_with_Rust_installation.sh &&\
./07_user_Personalization.sh &&\
sudo ./08_sudo_Flatpak_config_installation.sh &&\
sudo ./09_sudo_NonFree.sh
```

The first script (`01_sudo_Repo_setup_First_program_batch.sh`) will change the default shell from `bash` to `zsh`. For the changes to take effect it is required to reboot the system. Then, the following script will add to the corresponding shell configuration file (`.zshrc`) the settings for using Miniconda and changing the shell's prompt.

```bash
./10_user_PostReboot_Miniconda_and_shell_setup.sh
```

*Note that the full setup will take about 30Gb of disk space.*


### Helper functions

In this file a set of variables such as the Debian version to be installed (*e.g.* `trixie`) are defined as well as some functions to log the progress of the installation and get the directory where to download additional files.


### Configuration files

The scripts, make use of a number of configuration files for the customization. These are organized into program/categories folders (*e.g.* shell, system) and it is in these folders where the backups would be stored.

1.  Manual configuration

    Compiz configuration requires to import the file (`Configuration_files/compiz/compiz_debian_custom.profile`) from `CompizConfig Settings Manager` (CCSM) using the Preferences option.


### Download folder

The script will create a directory to store all the installation files in the download directory in a folder `Installation_files`. This can be reused in other installations by placing at the same level as the `Scripts` folder.
