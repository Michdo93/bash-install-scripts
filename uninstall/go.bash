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

# Deinstallieren von Golang
run_command "apt purge golang-go -y" "$(check_sudo)"

# Löschen von golang-Paketen
run_command "apt autoremove --purge -y" "$(check_sudo)"

# Löschen von golang-Konfigurationsdateien
run_command "rm -rf /usr/lib/go /usr/local/go" "$(check_sudo)"
