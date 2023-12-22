#!/bin/bash

# Benutzer auffordern, das neue Passwort für icinga_ido einzugeben
read -sp "Geben Sie das neue Passwort für 'icinga_ido' ein: " new_password
echo

# Benutzer auffordern, das neue Passwort zu bestätigen
read -sp "Bestätigen Sie das neue Passwort: " confirm_password
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

# MariaDB-Befehle
mariadb_user="root"
mariadb_password="mariadb_root"
mariadb_database="icinga_ido_db"

# MariaDB-Befehl zum Ändern des Passworts
mariadb_commands="
ALTER USER 'icinga_ido'@'localhost' IDENTIFIED BY '$new_password';
FLUSH PRIVILEGES;
EXIT;
"

# Ausführung der MariaDB-Befehle
echo "$mariadb_commands" | run_command "mysql -u \"$mariadb_user\" -p\"$mariadb_password\" \"$mariadb_database\"" "$(check_sudo)"
