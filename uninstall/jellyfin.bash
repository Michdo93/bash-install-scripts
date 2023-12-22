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

# Jellyfin-Dienst stoppen und deaktivieren
sudo_available=$(check_sudo)

run_command "systemctl stop jellyfin.service" "$sudo_available"
run_command "systemctl disable jellyfin.service" "$sudo_available"

# Deinstalliere Jellyfin
run_command "apt remove --purge jellyfin -y" "$sudo_available"

# Entferne das Jellyfin-Repository
JELLYFIN_KEYRING="/usr/share/keyrings/jellyfin-archive-keyring.gpg"
JELLYFIN_LIST="/etc/apt/sources.list.d/jellyfin.list"

run_command "rm $JELLYFIN_KEYRING" "$sudo_available"
run_command "rm $JELLYFIN_LIST" "$sudo_available"

# Aktualisiere die Paketliste
run_command "apt update" "$sudo_available"
