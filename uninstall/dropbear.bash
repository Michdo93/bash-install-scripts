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

# Stoppen und Deaktivieren von Dropbear-Diensten (falls gestartet)
run_command "systemctl stop dropbear.service" "$(check_sudo)"
run_command "systemctl disable dropbear.service" "$(check_sudo)"

# Optionale Deinstallation von Dropbear
run_command "apt purge dropbear -y" "$(check_sudo)"
