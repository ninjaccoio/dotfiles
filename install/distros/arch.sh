install_packages() {
    echo "==> Installing packages with pacman..."

    sudo pacman -S --needed \
        hyprland \
        hyprpaper \
        quickshell \
        sddm

    if ! command -v paru >/dev/null 2>&1; then
        if [[ "$DISTRO_ID" == "cachyos" ]]; then
            sudo pacman -S --needed paru
        else
            echo "ERROR: paru is required but is not installed."
            echo "Install paru first, then run this installer again."
            return 1
        fi
    fi

    echo
    echo "==> Installing AUR packages with paru..."

    paru -S --needed \
        brave-bin \
        visual-studio-code-bin \
        sddm-silent-theme
}
