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

# Deinstallieren von Visual Studio Code und zugehörigen Paketen
run_command "apt purge --autoremove code -y" "$sudo_available"

# Entfernen des Visual Studio Code-Repositorys
run_command "rm /etc/apt/sources.list.d/vscode.list" "$sudo_available"

# Aktualisieren des Systems
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

echo "Deinstallation von Visual Studio Code abgeschlossen."
