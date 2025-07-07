#!/bin/bash

required_pkgs="git zsh vim bat"

if (($(apt list $required_pkgs 2>/dev/null | grep -c -v '\[installed\]') > 1)); then
    echo "Installing missing packages..."
    cmd="apt install -y $required_pkgs"

    if (($EUID == 0)); then
        apt update
        $cmd
    else
        if type sudo 2> /dev/null; then
            sudo apt update
            sudo $cmd
        else
            echo "Error: sudo is not installed. Install it or install the following required packages as root:"
            echo "apt update &&" $cmd
        fi
    fi
fi

# fzf version for Debian 12 is outdated, install directly from github
if ! type fzf 2> /dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --no-update-rc --completion --key-bindings --no-bash --no-fish
fi

# Clone the bare repository
if ! git clone --bare git@github.com:Ik-12/dotfiles.git $HOME/.cfg; then
    echo "Error: Failed to clone the repository. Make sure ssh-agent forwarding is working."
    exit 1
fi

# Define variables for the repository and work-tree
GIT_DIR="$HOME/.cfg"
WORK_TREE="$HOME"

# Configure git to hide untracked files in this repository
git --git-dir=$GIT_DIR --work-tree=$WORK_TREE config --local status.showUntrackedFiles no

# Attempt to check out the content of the repository
echo "Checking out dotfiles..."
cd
if ! git --git-dir=$GIT_DIR --work-tree=$WORK_TREE checkout; then
    echo "Conflict detected. Renaming existing files to '-bak'..."

    # Loop through the conflicting files and rename them
    conflicted_files=$(git --git-dir=$GIT_DIR --work-tree=$WORK_TREE checkout 2>&1 | egrep '^\s+' | awk -F/ '{print $1}' | uniq)
    for file in $conflicted_files; do
        echo "Renaming $file to $file-bak"
        mv "$HOME/$file" "$HOME/${file}-bak"
    done

    # Retry the checkout
    git --git-dir=$GIT_DIR --work-tree=$WORK_TREE checkout
fi

git --git-dir=$GIT_DIR --work-tree=$WORK_TREE submodule init
git --git-dir=$GIT_DIR --work-tree=$WORK_TREE submodule update

echo "Dotfiles repository successfully checked out."
echo
echo "After testing zsh configuration works, change login shell using following command:"
echo 'sudo chsh -s $(which zsh) $(whoami)'
