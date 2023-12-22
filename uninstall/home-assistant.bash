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

# Deinstalliere Home Assistant
run_command "systemctl stop home-assistant.service" "$(check_sudo)"
run_command "systemctl disable home-assistant.service" "$(check_sudo)"
run_command "rm /etc/systemd/system/home-assistant.service" "$(check_sudo)"
run_command "userdel homeassistant" "$(check_sudo)"
run_command "rm -rf /home/homeassistant" "$(check_sudo)"

# Deinstalliere Python Virtual Environment und Abhängigkeiten
run_command "rm -rf /homeassistant_venv" "$(check_sudo)"
run_command "pip uninstall homeassistant -y" "$(check_sudo)"
run_command "apt remove --purge -y python3-pip build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev" "$(check_sudo)"

# Entferne Systemd-Service und Konfiguration
run_command "systemctl daemon-reload" "$(check_sudo)"
run_command "systemctl reset-failed" "$(check_sudo)"

echo "Home Assistant wurde erfolgreich deinstalliert."
