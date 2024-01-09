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

# Löschen des täglichen Cron-Jobs für AIDE
cronjob_line="0 0 * * * /usr/sbin/aide --check"
(crontab -l | grep -v "$cronjob_line") | crontab -

# Optionale Deinstallation von aide-Paket
run_command "apt purge aide -y" "$(check_sudo)"
