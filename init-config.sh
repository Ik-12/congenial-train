#!/bin/bash

# Clone the bare repository
git clone --bare git@github.com:Ik-12/dotfiles.git $HOME/.cfg 

# Define the alias for easier commands
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Configure git to hide untracked files in this repository
config config --local status.showUntrackedFiles no

# Attempt to check out the content of the repository
echo "Checking out dotfiles..."
if ! config checkout; then
    echo "Conflict detected. Renaming existing files to '-bak'..."

    # Loop through the conflicting files and rename them
    conflicted_files=$(config checkout 2>&1 | grep -oP '(?<=\s)\S+(?= already exists)')
    for file in $conflicted_files; do
        echo "Renaming $file to $file-bak"
        mv "$HOME/$file" "$HOME/${file}-bak"
    done

    # Retry the checkout
    config checkout
fi

echo "Dotfiles repository successfully checked out."
