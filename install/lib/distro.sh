# --------------------------------------------------
#
# Detect the current Linux distribution using
# /etc/os-release and store its identification data.
#
# --------------------------------------------------
detect_distribution() {
    if [[ ! -f /etc/os-release ]]; then
        echo "ERROR: Cannot detect Linux distribution."
        exit 1
    fi

    source /etc/os-release

    DISTRO_ID="$ID"
    DISTRO_LIKE="${ID_LIKE:-}"

    echo "Detected family: ${PRETTY_NAME:-$DISTRO_LIKE}"
    echo "Detected distribution: ${PRETTY_NAME:-$DISTRO_ID}"
}

# --------------------------------------------------
#
# Load the installation script for the detected
# Linux distribution.
#
# --------------------------------------------------
load_distro() {
    case "$DISTRO_ID" in
        cachyos)
            source "$DOTFILES/install/distros/cachyos.sh"
            ;;
        arch)
            source "$DOTFILES/install/distros/arch.sh"
            ;;
        *)
            if [[ " $DISTRO_LIKE " == *" arch "* ]]; then
                source "$DOTFILES/install/distros/arch.sh"
            elif [[ "$DISTRO_ID" == debian || "$DISTRO_ID" == ubuntu || " $DISTRO_LIKE " == *" debian "* ]]; then
                echo "ERROR: Debian package installation is not configured yet."
                exit 1
            else
                echo "ERROR: Unsupported distribution: $DISTRO_ID"
                exit 1
            fi
            ;;
    esac
}
