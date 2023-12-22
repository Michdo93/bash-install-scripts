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

# Kea DHCP-Dienst stoppen und deaktivieren
sudo_available=$(check_sudo)

run_command "systemctl stop kea-dhcp4-server" "$sudo_available"
run_command "systemctl disable kea-dhcp4-server" "$sudo_available"

# Deinstalliere Kea DHCP
run_command "apt remove --purge kea-dhcp4-server -y" "$sudo_available"

# Aktualisiere die Paketliste
run_command "apt update" "$sudo_available"
