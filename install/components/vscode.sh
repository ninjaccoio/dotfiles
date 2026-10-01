configure_vscode() {
    local extension

    if ! command -v code >/dev/null 2>&1; then
        echo "ERROR: VS Code CLI (code) not found."
        return 1
    fi

    echo "==> Installing VS Code extensions..."

    while IFS= read -r extension || [[ -n "$extension" ]]; do
        [[ -z "$extension" || "$extension" == \#* ]] && continue
        code --install-extension "$extension"
    done < "$DOTFILES/vscode/extensions.txt"

    # Optional user customizations, when exported into the repository.
    if [[ -f "$DOTFILES/vscode/keybindings.json" ]]; then
        link_config "$DOTFILES/vscode/keybindings.json" "$CONFIG/Code/User/keybindings.json"
    fi
    if [[ -d "$DOTFILES/vscode/snippets" ]]; then
        link_config "$DOTFILES/vscode/snippets" "$CONFIG/Code/User/snippets"
    fi
}
