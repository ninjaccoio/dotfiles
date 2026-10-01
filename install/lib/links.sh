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

    if [[ -L "$target" ]]; then
        echo "    Replacing existing symlink."
        rm "$target"

    elif [[ -e "$target" ]]; then
        echo "    Existing configuration found."
        echo "    Backing up to $BACKUP_DIR/$name"

        mkdir -p "$BACKUP_DIR"

        mv "$target" "$BACKUP_DIR/$name"
    fi

    ln -s "$source" "$target"

    echo "    $target -> $source"
}

install_dotfiles() {
    mkdir -p "$CONFIG"
    mkdir -p "$CONFIG/Code/User"

    link_config \
        "$DOTFILES/hypr/$MACHINE" \
        "$CONFIG/hypr"

    link_config \
        "$DOTFILES/quickshell" \
        "$CONFIG/quickshell"

    link_config \
        "$DOTFILES/vscode/settings.json" \
        "$CONFIG/Code/User/settings.json"
}