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

# Deinstallieren von Webmin und Webmin UFW-Modul
run_command "apt remove --purge webmin webmin-ufw -y" "$sudo_available"
run_command "apt autoremove -y" "$sudo_available"

# Löschen von Webmin-Konfigurationsdatei
run_command "rm /etc/apt/sources.list.d/webmin.list" "$sudo_available"

# Aktualisieren des Systems
run_command "apt update" "$sudo_available"

echo "Deinstallation abgeschlossen."
