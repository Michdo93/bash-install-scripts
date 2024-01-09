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

# Deinstallieren von Grafana
run_command "apt purge grafana -y" "$(check_sudo)"

# Löschen von Grafana-Konfigurationsdateien und Daten
run_command "rm -rf /etc/grafana /var/lib/grafana" "$(check_sudo)"

# Entfernen des Repositories
run_command "add-apt-repository --remove \"deb https://packages.grafana.com/oss/deb stable main\"" "$(check_sudo)"

# Aktualisieren von apt nach Entfernen des Repositories
run_command "apt update" "$(check_sudo)"
