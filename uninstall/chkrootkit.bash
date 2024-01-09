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

# Entfernen der crontab-Einträge für chkrootkit
run_command "sed -i '/chkrootkit/d' /etc/crontab" "$(check_sudo)"

# Optionale Deinstallation von chkrootkit
run_command "apt purge chkrootkit -y" "$(check_sudo)"
