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

# OwnCloud deaktivieren und entfernen
run_command "systemctl stop owncloud.service" "$sudo_available"
run_command "systemctl disable owncloud.service" "$sudo_available"
run_command "rm /etc/systemd/system/owncloud.service" "$sudo_available"

# Apache-Konfigurationen deaktivieren
run_command "a2dissite owncloud.conf" "$sudo_available"
run_command "systemctl restart apache2" "$sudo_available"
run_command "rm /etc/apache2/sites-available/owncloud.conf" "$sudo_available"

# Datenverzeichnis sichern (optional)
backup_dir="/var/www/html/owncloud/data_backup"
run_command "mv /var/www/html/owncloud/data $backup_dir" "$sudo_available"

# OwnCloud-Verzeichnis löschen
run_command "rm -rf /var/www/html/owncloud" "$sudo_available"

# MariaDB-Datenbank löschen (Vorsicht: Das löscht alle Daten!)
run_command "mysql -u root -p -e 'DROP DATABASE IF EXISTS owncloud;'" "$sudo_available"
run_command "mysql -u root -p -e 'DROP USER IF EXISTS owncloud;'" "$sudo_available"

# Paketdatenbank aktualisieren
run_command "apt autoremove -y" "$sudo_available"
run_command "apt clean" "$sudo_available"
