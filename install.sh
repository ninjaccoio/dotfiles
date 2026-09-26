#!/usr/bin/env bash

set -e

DOTFILES="$HOME/dotfiles"

echo "==> Installing packages..."

sudo pacman -S --needed \
    hyprland \
    quickshell

echo "==> Creating config directory..."

mkdir -p "$HOME/.config"

echo "==> Linking Hyprland..."

ln -sfn "$DOTFILES/hypr" "$HOME/.config/hypr"

echo "==> Linking Quickshell..."

ln -sfn "$DOTFILES/quickshell" "$HOME/.config/quickshell"

echo "==> Done!"