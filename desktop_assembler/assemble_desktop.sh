#!/bin/bash

config_paths=~/dotfiles/desktop_assembler/config_paths.csv
rel_path=$HOME # for testing: change this to a test folder to verify code works

# install required packages
echo "Installing required packages..."
pacman -S --needed - < pkglist.txt

# import dotfiles
for item in $(cat $config_paths | tail -n +2)
do 
    pkg_name=$(echo $item | cut -d "," -f1)
    dot_path=$(echo $item | cut -d "," -f2)
    loc_path=$(echo $item | cut -d "," -f3)
    dir_needed=$(echo $item | cut -d "," -f4)
    folder_status=$(echo $item | cut -d "," -f5)

    # for config files with no directory creation needed
    if $(echo $folder_status | grep -q N) && $(echo $dir_needed | grep -q None); then
        cp -v "$HOME/$dot_path" "$rel_path/$loc_path"
    fi

    # for config files which need directory created in $HOME/.config
    if $(echo $dir_needed | grep -qv None); then # grep -v for invert-match
        mkdir -v "$rel_path/$dir_needed"
        cp -v "$HOME/$dot_path" "$rel_path/$loc_path"
    fi

    # for config folders
    if $(echo $folder_status | grep -q Y); then
        cp -rv "$HOME/$dot_path" "$rel_path/$loc_path"
    fi

    echo "$pkg_name imported"
done


# sublime text
echo "Installing sublime text..."
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
pacman -Syu sublime-text

# LaTeX installation
echo "Installing LaTeX..."
pacman -S --needed - < texlist.txt

# python packages
echo "Installing pip..."
wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py

echo "Installing python packages"
pip install -r python_pkglist.txt

echo "Done!"