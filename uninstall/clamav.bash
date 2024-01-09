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

# Entfernen der crontab-Einträge für clamscan
run_command "sed -i '/clamscan/d' /etc/crontab" "$(check_sudo)"

# Optionale Deinstallation von ClamAV
run_command "apt purge clamav clamav-freshclam clamav-docs -y" "$(check_sudo)"
