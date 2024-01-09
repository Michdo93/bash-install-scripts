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

# Deaktivieren und Stoppen von Apache (falls gestartet)
run_command "systemctl disable apache2.service" "$(check_sudo)"
run_command "systemctl stop apache2.service" "$(check_sudo)"

# Optionale Deinstallation von Apache
run_command "apt purge apache2 -y" "$(check_sudo)"
