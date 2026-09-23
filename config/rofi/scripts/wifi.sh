#!/usr/bin/env bash

# ============================================================
# Wi-Fi menu
# Rofi provides the UI, NetworkManager handles the connection.
# ============================================================

ROFI_THEME="$HOME/.config/rofi/wifi.rasi"

rofi_menu() {
    rofi -dmenu -i -p "" -theme "$ROFI_THEME" "$@"
}

# Make sure Wi-Fi is enabled.
if [[ "$(nmcli -t -f WIFI general)" != "enabled" ]]; then
    choice=$(printf "Enable Wi-Fi\nCancel" | rofi_menu)

    [[ "$choice" == "Enable Wi-Fi" ]] || exit 0

    nmcli radio wifi on
    sleep 1
fi

# Ask NetworkManager for a fresh scan.
nmcli device wifi rescan >/dev/null 2>&1

# Build a unique list of visible SSIDs.
networks=$(
    nmcli -t -f SSID device wifi list |
    awk 'NF && !seen[$0]++'
)

[[ -n "$networks" ]] || {
    printf "No Wi-Fi networks found" | rofi_menu
    exit 0
}

ssid=$(printf '%s\n' "$networks" | rofi_menu)

[[ -n "$ssid" ]] || exit 0

# First try the connection normally.
# This automatically works for open networks and saved profiles.
if nmcli connection up id "$ssid" >/dev/null 2>&1; then
    notify-send "Wi-Fi" "Connected to $ssid"
    exit 0
fi

# If there is no saved connection, ask for a password.
password=$(
    printf "" |
        rofi -dmenu \
             -password \
             -p "" \
             -mesg "Password for $ssid" \
             -theme "$ROFI_THEME"
)

[[ -n "$password" ]] || exit 0

if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
    notify-send "Wi-Fi" "Connected to $ssid"
else
    notify-send -u critical "Wi-Fi" "Could not connect to $ssid"
fi