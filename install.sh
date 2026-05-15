#!/usr/bin/env bash

# Dotfiles array
dotfiles=$(find "$(pwd -P)" -maxdepth 2 -mindepth 2 -not -wholename "*/.git/*")

# Iterate dotfiles array and symlink to appropriate $HOME path
for path in $dotfiles; do
    # Path directory name and base name
    path_dirname=$(basename "$(dirname "$path")")
    path_basename=$(basename "$path")

    # Determine symlink path & opts
    symlink_path="${HOME}/"
    symlink_opts="-sf"

    if [[ -d "$path" ]]; then
        symlink_opts="${symlink_opts}n"
    fi

    if [[ "$path_dirname" == "home" ]]; then
        symlink_path+=".${path_basename}"
    else
        symlink_path+=".${path_dirname}/${path_basename}"
    fi

    # Symlink dotfile
    ln "$symlink_opts" "$path" "$symlink_path"
done
