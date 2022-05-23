# Desktop Assembler

This is the folder containing the scripts which install/backup all of the required packages for my workflow. In particular this folder contains:

* /scripts/assemble_desktop.sh - This is a bash script which installs all of the required packages and copies the config files from my dotfiles folder to the corresponding local directories. Packages listed in pkglist.txt are installed, and the script then uses the config_paths.csv file to find where to put each of the config files/folders.
* /scripts/backup_dotfiles.sh - This is a bash script which copies dotfiles from the local directories into my ditfiles folder. The code uses the same loop in assemble_desktop.sh only with the copy commands in reverse.

The scripts assemble_desktop.sh and backup_dotfiles.sh are scalable, in the sense that if I add any packages to my workflow, the only files that need to be updated are the helper files pkglist.txt and config_paths.csv.


### Todo
* fix rofi themes to match update