#!/bin/bash

# Funktion zum Prüfen, ob sudo verfügbar ist
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

# Deinstallation von Paketen
sudo_available=$(check_sudo)

# Stoppe Icinga2-Dienst
run_command "systemctl stop icinga2" "$sudo_available"

# Entferne Icinga2-Pakete
run_command "apt remove --purge icinga2 monitoring-plugins -y" "$sudo_available"

# Deinstalliere icinga2-ido-mysql
run_command "apt remove --purge icinga2-ido-mysql -y" "$sudo_available"

# Entferne Icinga2-Schlüssel
run_command "apt-key del D8A3CAA50A9F0C15" "$sudo_available"

# Lösche Icinga2-Apt-Quelle
run_command "rm /etc/apt/sources.list.d/icinga-focal.list" "$sudo_available"

# Lösche Datenbank und Benutzer in MariaDB
run_command "mysql -u root -p -e 'DROP DATABASE IF EXISTS icinga_ido_db;'" "$sudo_available"
run_command "mysql -u root -p -e 'DROP USER IF EXISTS icinga_ido@localhost;'" "$sudo_available"
run_command "mysql -u root -p -e 'DROP DATABASE IF EXISTS icingaweb2;'" "$sudo_available"
run_command "mysql -u root -p -e 'DROP USER IF EXISTS icingaweb2user@localhost;'" "$sudo_available"

# Deinstalliere icingaweb2 und icingacli
run_command "apt remove --purge icingaweb2 icingacli -y" "$sudo_available"

# Aktualisiere Paketlisten
run_command "apt update" "$sudo_available"
