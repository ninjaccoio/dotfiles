#!/usr/bin/env bash

app_class=$(hyprctl activewindow -j | jq -r '.class // empty')

case "$app_class" in
    "code")
        echo "󰨞"
        ;;
    "kitty")
        echo "󰄛"
        ;;
    "org.kde.dolphin")
        echo "󰉋"
        ;;
    "")
        echo ""
        ;;
    *)
        echo "󰣆"
        ;;
esac