#!/bin/bash

# Benutzer auffordern, das neue InfluxDB-Passwort einzugeben
read -sp "Geben Sie das neue InfluxDB-Passwort für den Benutzer 'admin' ein: " new_password
echo

# Benutzer auffordern, das neue InfluxDB-Passwort zu bestätigen
read -sp "Bestätigen Sie das neue InfluxDB-Passwort: " confirm_password
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

# InfluxDB-Benutzer "admin" Passwort ändern
run_command "influx user password -n admin -o $INFLUX_ORG_ID -p $INFLUX_PASSWORD -w $new_password" "$(check_sudo)"
