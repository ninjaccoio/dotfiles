configure_sddm() {
    local metadata="/usr/share/sddm/themes/silent/metadata.desktop"
    local preset="/usr/share/sddm/themes/silent/configs/silvia.conf"

    echo "==> Configuring SDDM..."

    if [[ ! -f "$metadata" || ! -f "$preset" ]]; then
        echo "ERROR: SilentSDDM metadata or silvia preset not found."
        exit 1
    fi

    sudo install -Dm644 \
        "$DOTFILES/sddm/sddm.conf" \
        /etc/sddm.conf.d/10-dotfiles.conf

    sudo sed -i \
        's|^ConfigFile=.*|ConfigFile=configs/silvia.conf|' \
        "$metadata"

    sudo systemctl enable sddm.service
}