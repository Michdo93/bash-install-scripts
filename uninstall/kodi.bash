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

# Kodi-Dienst stoppen und deaktivieren
sudo_available=$(check_sudo)

run_command "systemctl stop kodi.service" "$sudo_available"
run_command "systemctl disable kodi.service" "$sudo_available"

# Deinstalliere Kodi
run_command "apt remove --purge kodi kodi-bin -y" "$sudo_available"

# Entferne die Kodi-Service-Datei
run_command "rm /etc/systemd/system/kodi.service" "$sudo_available"

# Aktualisiere die Paketliste
run_command "apt update" "$sudo_available"
