# --------------------------------------------------
#
# Select the machine type and set the corresponding
# MACHINE variable.
#
# --------------------------------------------------
select_machine() {
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
            echo "ERROR: Invalid option."
            exit 1
            ;;
    esac

    echo
    echo "Selected machine: $MACHINE"
}

# --------------------------------------------------
#
# check if exists all the configuration
#
# --------------------------------------------------
validate_dotfiles() {
    [[ -d "$DOTFILES/hypr/$MACHINE" ]] || {
        echo "ERROR: Missing Hyprland configuration for $MACHINE."
        exit 1
    }

    [[ -d "$DOTFILES/quickshell/$MACHINE" ]] || {
        echo "ERROR: Missing Quickshell configuration for $MACHINE."
        exit 1
    }

    [[ -f "$DOTFILES/vscode/settings.json" ]] || {
        echo "ERROR: Missing VS Code settings."
        exit 1
    }

    [[ -f "$DOTFILES/vscode/extensions.txt" ]] || {
        echo "ERROR: Missing VS Code extension list."
        exit 1
    }

    [[ -f "$DOTFILES/sddm/sddm.conf" ]] || {
        echo "ERROR: Missing SDDM configuration."
        exit 1
    }
}
