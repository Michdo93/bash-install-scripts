#!/bin/bash

# Benutzer auffordern, das neue MariaDB-Passwort einzugeben
read -sp "Geben Sie das neue MariaDB-Passwort für den Benutzer 'root' ein: " new_password

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

# MariaDB-Passwort ändern
run_command "mysqladmin -u root -p'$new_password' password \"$new_password\"" "$(check_sudo)"

# MariaDB-Service neu laden
run_command "systemctl restart mariadb.service" "$(check_sudo)"
