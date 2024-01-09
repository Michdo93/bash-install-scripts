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

# HABApp-Dienst deaktivieren und stoppen
run_command "systemctl stop habapp.service" "$(check_sudo)"
run_command "systemctl disable habapp.service" "$(check_sudo)"

# HABApp Virtual Environment und Installationsverzeichnis löschen
HABAPP_DIR="/opt/habapp"

run_command "rm -rf $HABAPP_DIR" "$(check_sudo)"
run_command "rm -rf /etc/openhab/habapp" "$(check_sudo)"

# HABApp systemd-Service-Datei löschen
run_command "rm -f /etc/systemd/system/habapp.service" "$(check_sudo)"
