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

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"
run_command "apt install aide -y" "$sudo_available"

# Initialisieren von AIDE (erstes Mal nach der Installation)
run_command "aideinit" "$sudo_available"

# Hinzufügen eines täglichen Cron-Jobs für AIDE
cronjob_line="0 0 * * * /usr/sbin/aide --check"
(crontab -l ; echo "$cronjob_line") | sort - | uniq - | crontab -

# Optional: Hier kannst du den Cron-Job manuell starten, um AIDE sofort auszuführen.
run_command "/usr/sbin/aide --check" "$sudo_available"
