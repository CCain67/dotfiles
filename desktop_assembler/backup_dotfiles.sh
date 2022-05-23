#!/bin/bash

config_paths=~/dotfiles/desktop_assembler/config_paths.csv
rel_path=$HOME # for testing

for item in $(cat $config_paths | tail -n +2)
do 
    pkg_name=$(echo $item | cut -d "," -f1)
    dot_path=$(echo $item | cut -d "," -f2)
    loc_path=$(echo $item | cut -d "," -f3)
    dir_needed=$(echo $item | cut -d "," -f4)
    folder_status=$(echo $item | cut -d "," -f5)

    # for config files with no directory creation needed
    if $(echo $folder_status | grep -q N) && $(echo $dir_needed | grep -q None); then
        cp -v "$rel_path/$loc_path" "$HOME/$dot_path"
    fi

    # for config files which need directory created in $HOME/.config
    if $(echo $dir_needed | grep -qv None); then # grep -v for invert-match
        cp -v "$rel_path/$loc_path" "$HOME/$dot_path"
    fi

    # for config folders
    if $(echo $folder_status | grep -q Y); then
        cp -rv "$rel_path/$loc_path" "$HOME/$dot_path"
    fi

    echo "$pkg_name copied"
done

# git add .
# git commit -m "$1"
# git push origin master