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

# Stoppen und Deinstallieren des ISC DHCP Servers
sudo_available=$(check_sudo)

# Stopp des ISC DHCP Server-Dienstes
run_command "systemctl stop isc-dhcp-server" "$sudo_available"

# Deinstalliere den ISC DHCP Server
run_command "apt remove --purge isc-dhcp-server -y" "$sudo_available"

# Entferne die Konfigurationsdateien
run_command "rm -rf /etc/dhcp" "$sudo_available"

# Entferne die Systemd-Service-Datei
run_command "rm /etc/systemd/system/isc-dhcp-server.service" "$sudo_available"

# Aktualisiere die Paketliste
run_command "apt update" "$sudo_available"
