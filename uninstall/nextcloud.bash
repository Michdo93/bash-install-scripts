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

# Nextcloud-Dienst stoppen und deaktivieren
run_command "systemctl stop nextcloud.service" "$sudo_available"
run_command "systemctl disable nextcloud.service" "$sudo_available"

# Apache-Konfiguration für Nextcloud entfernen
run_command "a2dissite nextcloud.conf" "$sudo_available"
run_command "rm /etc/apache2/sites-available/nextcloud.conf" "$sudo_available"
run_command "systemctl restart apache2" "$sudo_available"

# Nextcloud-Verzeichnis löschen
run_command "rm -rf /var/www/html/nextcloud/" "$sudo_available"

# Abschließende Aufräumarbeiten (optional)
run_command "apt clean" "$sudo_available"
