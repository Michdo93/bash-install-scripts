#!/bin/bash

# Benutzer auffordern, das neue MariaDB-Passwort einzugeben
read -sp "Geben Sie das neue MariaDB-Passwort für den Benutzer 'nextcloud' ein: " new_password
echo

# Benutzer auffordern, das neue MariaDB-Passwort zu bestätigen
read -sp "Bestätigen Sie das neue MariaDB-Passwort: " confirm_password
echo

# Überprüfen, ob die eingegebenen Passwörter übereinstimmen
if [ "$new_password" != "$confirm_password" ]; then
    echo "Fehler: Die eingegebenen Passwörter stimmen nicht überein."
    exit 1
fi

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

# MariaDB-Passwort für den Benutzer "nextcloud" ändern
run_command "mysql -u nextcloud -p'$new_password' -e \"ALTER USER 'nextcloud'@'localhost' IDENTIFIED BY '$new_password';\"" "$(check_sudo)"

# MariaDB-Service neu laden
run_command "systemctl restart mariadb.service" "$(check_sudo)"
