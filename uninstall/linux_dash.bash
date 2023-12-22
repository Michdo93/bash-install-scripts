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

# Service stoppen und deaktivieren
sudo_available=$(check_sudo)

run_command "systemctl stop linux-dash.service" "$sudo_available"
run_command "systemctl disable linux-dash.service" "$sudo_available"

# Lösche das Git-Repository
run_command "rm -rf /var/www/html/linux-dash" "$sudo_available"

# Lösche die Service-Datei
run_command "rm /etc/systemd/system/linux-dash.service" "$sudo_available"

# Aktualisiere die Paketliste
run_command "apt update" "$sudo_available"
