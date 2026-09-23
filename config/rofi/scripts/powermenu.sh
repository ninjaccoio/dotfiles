#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/powermenu.rasi"

menu() {
    rofi -dmenu -i -p "" -theme "$ROFI_THEME"
}

confirm() {
    printf "Cancel\nConfirm" | menu
}

choice=$(printf "Suspend\nReboot\nShutdown" | menu)

case "$choice" in
    "Suspend")
        systemctl suspend
        ;;

    "Reboot")
        [[ "$(confirm)" == "Confirm" ]] && systemctl reboot
        ;;

    "Shutdown")
        [[ "$(confirm)" == "Confirm" ]] && systemctl poweroff
        ;;
esac