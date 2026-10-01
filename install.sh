#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

source "$DOTFILES/install/lib/common.sh"
source "$DOTFILES/install/lib/distro.sh"
source "$DOTFILES/install/lib/links.sh"
source "$DOTFILES/install/components/sddm.sh"
source "$DOTFILES/install/components/vscode.sh"

detect_distribution
select_machine
validate_dotfiles

load_distro

install_packages
configure_sddm
install_dotfiles
configure_vscode

echo
echo "================================"
echo "       Installation done!"
echo "================================"
echo
echo "Machine:      $MACHINE"
echo "Distribution: ${PRETTY_NAME:-$DISTRO_ID}"
echo
