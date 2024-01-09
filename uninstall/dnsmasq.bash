#!/bin/bash

# Funktion, um zu prüfen, ob sudo verfügbar ist
check_sudo() {
    if command -v sudo &> /dev/null; then
        echo "sudo"
    else
        echo ""
    fi
}

# Funktion zum Ausführen von Befehlen mit oder ohne sudo
run_command() {
    local cmd="$1"
    local sudo_available="$2"

    if [ -n "$sudo_available" ]; then
        sudo $cmd
    else
        $cmd
    fi
}

# Stoppen und Deaktivieren von dnsmasq (falls gestartet)
run_command "systemctl stop dnsmasq" "$(check_sudo)"
run_command "systemctl disable dnsmasq" "$(check_sudo)"

# Optionale Deinstallation von dnsmasq
run_command "apt purge dnsmasq -y" "$(check_sudo)"

