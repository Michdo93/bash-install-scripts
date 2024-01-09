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

# Deinstallieren von MariaDB
run_command "systemctl stop mariadb.service" "$sudo_available"
run_command "systemctl disable mariadb.service" "$sudo_available"
run_command "apt remove --purge mariadb-server -y" "$sudo_available"

# Deinstallieren von Apache2
run_command "systemctl stop apache2" "$sudo_available"
run_command "systemctl disable apache2" "$sudo_available"
run_command "apt remove --purge apache2 -y" "$sudo_available"

# Deinstallieren von PHP und anderen Abhängigkeiten
run_command "apt remove --purge php php-gd php-mbstring php-mysqlnd php-curl php-xml php-cli php-soap php-intl php-xmlrpc php-zip php-common php-opcache php-gmp php-imagick php-pgsql -y" "$sudo_available"
