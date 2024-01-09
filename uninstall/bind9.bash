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

# Deaktivieren und Stoppen von bind9 (falls gestartet)
run_command "systemctl disable bind9.service" "$(check_sudo)"
run_command "systemctl stop bind9.service" "$(check_sudo)"

# Optionale Deinstallation von bind9
run_command "apt purge bind9 -y" "$(check_sudo)"
