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

# Entfernen von VirtualBox und zugehörigen Paketen
run_command "apt purge --autoremove virtualbox* -y" "$sudo_available"

# Entfernen des Benutzers aus der vboxusers-Gruppe
run_command "deluser $USER vboxusers" "$sudo_available"

# Entfernen von VirtualBox-Gastzusätzen und VirtualBox-Gast-X11
run_command "apt purge --autoremove virtualbox-guest-* -y" "$sudo_available"

# Entfernen des VirtualBox-Erweiterungspakets
run_command "apt purge --autoremove virtualbox-ext-pack -y" "$sudo_available"

# Aktualisieren des Systems
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

echo "Deinstallation von VirtualBox abgeschlossen."
