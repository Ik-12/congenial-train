#!/bin/bash

# Function to check if a package is installed, and install it if not
install_if_missing() {
    local package=$1
    if ! dpkg -l | grep -qw "$package"; then
        echo "Installing $package..."
        sudo apt update
        sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
}

# Install required packages
install_if_missing git
install_if_missing zsh
install_if_missing vim
install_if_missing bat

# Clone the bare repository
git clone --bare git@github.com:Ik-12/dotfiles.git $HOME/.cfg 

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
