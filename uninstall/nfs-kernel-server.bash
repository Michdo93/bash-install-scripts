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
        sudo "$cmd"
    else
        "$cmd"
    fi
}

# NFS-Server-Dienst stoppen und deaktivieren
run_command "systemctl stop nfs-kernel-server.service" "$sudo_available"
run_command "systemctl disable nfs-kernel-server.service" "$sudo_available"

# NFS-Server-Pakete entfernen
run_command "apt remove --purge nfs-kernel-server -y" "$sudo_available"
run_command "apt autoremove -y" "$sudo_available"

# Abschließende Aufräumarbeiten (optional)
run_command "apt clean" "$sudo_available"
