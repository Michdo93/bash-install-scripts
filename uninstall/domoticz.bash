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

# Stoppen und Deaktivieren von Domoticz-Diensten (falls gestartet)
run_command "systemctl stop domoticz.service" "$(check_sudo)"
run_command "systemctl disable domoticz.service" "$(check_sudo)"

# Optionale Deinstallation von Domoticz
run_command "rm -rf /opt/domoticz" "$(check_sudo)"
run_command "rm /etc/systemd/system/domoticz.service" "$(check_sudo)"
run_command "rm -rf /$HOME/domoticz" "$(check_sudo)"

