#!/usr/bin/env bash

set -euo pipefail

# Directory del repository, indipendentemente da dove viene clonato.
DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"


# --------------------------------------------------
# Functions
# --------------------------------------------------

link_config() {
    local source="$1"
    local target="$2"
    local name

    name="$(basename "$target")"

    if [[ ! -e "$source" ]]; then
        echo "ERROR: Source does not exist: $source"
        exit 1
    fi

    echo "==> Configuring $name..."

    # Existing symlink: remove it.
    if [[ -L "$target" ]]; then
        echo "    Replacing existing symlink."
        rm "$target"

    # Existing real file/directory: back it up.
    elif [[ -e "$target" ]]; then
        echo "    Existing configuration found."
        echo "    Backing up to $BACKUP_DIR/$name"

        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$name"
    fi

    ln -s "$source" "$target"

    echo "    $target -> $source"
}


# --------------------------------------------------
# Header
# --------------------------------------------------

echo "================================"
echo "       Dotfiles installer"
echo "================================"
echo
echo "Select machine:"
echo
echo "  1) Notebook"
echo "  2) Desktop"
echo

read -rp "> " choice

case "$choice" in
    1)
        MACHINE="notebook"
        ;;
    2)
        MACHINE="desktop"
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

echo
echo "Selected machine: $MACHINE"
echo


# --------------------------------------------------
# Validate
# --------------------------------------------------

[[ -d "$DOTFILES/hypr/$MACHINE" ]] || {
    echo "ERROR: Missing Hyprland configuration for $MACHINE."
    exit 1
}

[[ -d "$DOTFILES/quickshell/$MACHINE" ]] || {
    echo "ERROR: Missing Quickshell configuration for $MACHINE."
    exit 1
}


# --------------------------------------------------
# Packages
# --------------------------------------------------

echo "==> Installing packages..."

sudo pacman -S --needed 
    hyprland 
    quickshell


# --------------------------------------------------
# Config
# --------------------------------------------------

mkdir -p "$CONFIG"

link_config 
    "$DOTFILES/hypr/$MACHINE" 
    "$CONFIG/hypr"

link_config 
    "$DOTFILES/quickshell" 
    "$CONFIG/quickshell"


# --------------------------------------------------
# Done
# --------------------------------------------------

echo
echo "================================"
echo "       Installation done!"
echo "================================"
echo
echo "Machine: $MACHINE"
echo