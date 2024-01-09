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

# openHAB deinstallieren
run_command "systemctl stop openhab.service" "$sudo_available"
run_command "systemctl disable openhab.service" "$sudo_available"
run_command "apt purge openhab openhab-addons -y" "$sudo_available"
run_command "apt autoremove -y" "$sudo_available"
run_command "apt clean" "$sudo_available"

# Entfernen der openHAB-Repository-Konfiguration
run_command "rm /etc/apt/sources.list.d/openhab.list" "$sudo_available"
run_command "rm /usr/share/keyrings/openhab.gpg" "$sudo_available"
