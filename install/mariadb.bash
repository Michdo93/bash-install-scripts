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

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

run_command "apt install mariadb-server -y" "$sudo_available"

echo -e "mariadb_root\nmariadb_root\nY\nn\nY\nY\nY\n" | run_command "mysql_secure_installation" "$sudo_available"

run_command "systemctl start mariadb.service" "$sudo_available"
run_command "systemctl enable mariadb.service" "$sudo_available"
