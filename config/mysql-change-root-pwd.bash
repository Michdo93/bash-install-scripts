#!/bin/bash

# Benutzer auffordern, das neue MySQL-Passwort einzugeben
read -sp "Geben Sie das neue MySQL-Passwort für den Benutzer 'root' ein: " new_password
echo

# Benutzer auffordern, das neue MySQL-Passwort zu bestätigen
read -sp "Bestätigen Sie das neue MySQL-Passwort: " confirm_password
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

# MySQL-Passwort ändern
echo -e "[client]\npassword = $new_password" > ~/.my.cnf
run_command "mysql_config_editor set --login-path=local --host=localhost --user=root --password" "$(check_sudo)"

# MySQL-Privilegien aktualisieren und Service neu laden
run_command "mysql -e 'ALTER USER \"root\"@\"localhost\" IDENTIFIED WITH \"mysql_native_password\" BY \"$new_password\"; FLUSH PRIVILEGES;'" "$(check_sudo)"
run_command "systemctl restart mysql.service" "$(check_sudo)"
