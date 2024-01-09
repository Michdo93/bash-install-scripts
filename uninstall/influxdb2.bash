#!/bin/bash

# Funktion zum Prüfen, ob sudo verfügbar ist
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

# Stopp und Deinstallation von InfluxDB 2.0
sudo_available=$(check_sudo)

# Stopp InfluxDB-Dienst
run_command "systemctl stop influxdb.service" "$sudo_available"

# Deinstalliere InfluxDB 2.0
run_command "apt remove --purge influxdb2 -y" "$sudo_available"

# Entferne die InfluxDB Apt-Quelle und den GPG-Schlüssel
run_command "rm /etc/apt/sources.list.d/influxdata.list" "$sudo_available"
run_command "rm /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg" "$sudo_available"

# Aktualisiere die Paketliste
run_command "apt update" "$sudo_available"
