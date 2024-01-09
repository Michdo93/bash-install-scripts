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

# Deinstallieren von SQLite und anderen Paketen
run_command "apt remove --purge sqlite3 -y" "$sudo_available"

# Hier könntest du weitere Deinstallationsbefehle hinzufügen, je nachdem, was du installiert hast.

# Entfernen von Paketlisten und Aktualisieren des Systems
run_command "apt autoremove -y" "$sudo_available"
run_command "apt clean" "$sudo_available"
run_command "apt update" "$sudo_available"

echo "Deinstallation abgeschlossen."
