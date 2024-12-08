#!/bin/bash

echo "Installing missing packages..."
sudo apt update
sudo apt install -y git zsh vim bat

# Clone the bare repository
if ! git clone --bare git@github.com:Ik-12/dotfiles.git $HOME/.cfg; then
    echo "Error: Failed to clone the repository. Make sure ssh-agent forwarding if working."
    exit 1
fi

# Define variables for the repository and work-tree
GIT_DIR="$HOME/.cfg"
WORK_TREE="$HOME"

# Configure git to hide untracked files in this repository
git --git-dir=$GIT_DIR --work-tree=$WORK_TREE config --local status.showUntrackedFiles no

# Attempt to check out the content of the repository
echo "Checking out dotfiles..."
if ! git --git-dir=$GIT_DIR --work-tree=$WORK_TREE checkout; then
    echo "Conflict detected. Renaming existing files to '-bak'..."

    # Loop through the conflicting files and rename them
    conflicted_files=$(git --git-dir=$GIT_DIR --work-tree=$WORK_TREE checkout 2>&1 | egrep '^\s+')
    for file in $conflicted_files; do
        echo "Renaming $file to $file-bak"
        mv "$HOME/$file" "$HOME/${file}-bak"
    done

    # Retry the checkout
    git --git-dir=$GIT_DIR --work-tree=$WORK_TREE checkout
fi

echo "Dotfiles repository successfully checked out."
echo
echo "After testing zsh configuration works, change login shell using following command:"
echo 'sudo chsh -s $(which zsh) $(whoami)'
