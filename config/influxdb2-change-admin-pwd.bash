#!/bin/bash

# Benutzer auffordern, den neuen InfluxDB-Benutzernamen einzugeben
read -sp "Geben Sie den neuen InfluxDB-Benutzernamen für den Benutzer 'admin' ein: " new_username
echo

# Benutzer auffordern, den neuen InfluxDB-Benutzernamen zu bestätigen
read -sp "Bestätigen Sie den neuen InfluxDB-Benutzernamen: " confirm_username
echo

# Überprüfen, ob die eingegebenen Usernamen übereinstimmen
if [ "$new_username" != "$confirm_username" ]; then
    echo "Fehler: Die eingegebenen Benutzernamen stimmen nicht überein."
    exit 1
fi

# Benutzer auffordern, das neue InfluxDB-Passwort einzugeben
read -sp "Geben Sie das neue InfluxDB-Passwort für den Benutzer '$new_username' ein: " new_password
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

run_command "apt install expect -y" "sudo_available"

user_list_output=$(influx user list)

# Extrahiere die ID des Benutzers
user_id=$(echo "$user_list_output" | awk '/influxdb/{print $1}')

influx user update -i $user_id -n $new_username
influx user password -n $new_username

expect_script=$(cat << 'EOF'
spawn influx user password -i $user_id
expect '? Please type new password for "$user_id"' { send "$new_password\n" }
expect '? Please type new password for "$user_id" again' { send "$new_password\n" }
expect 'Successfully updated password for user "$user_id"' { send "\n" }
expect eof
EOF
)

# Führe das Expect-Skript aus
export user_id
export new_password
echo "$expect_script" | expect -
