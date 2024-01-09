#!/bin/bash

# Überprüfen, ob der Benutzer Root ist
if [ "$(id -u)" -ne 0 ]; then
    echo "Bitte als Root ausführen (mit sudo)." >&2
    exit 1
fi

# Fehlerbehandlung aktivieren
set -e

# Funktion, um zu prüfen, ob sudo verfügbar ist
check_sudo() {
    command -v sudo &> /dev/null && echo "sudo" || true
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

# Stoppen und Deaktivieren von Docker-Compose-Diensten
run_command "systemctl stop docker-compose.service" "$(check_sudo)"
run_command "systemctl disable docker-compose.service" "$(check_sudo)"

# Löschen von EmulatorJS-Diensten und Containern (ohne andere Docker-Anwendungen zu beeinträchtigen)
run_command "docker-compose down" "$(check_sudo)"
run_command "rm -rf /home/$USER/emulatorjs" "$(check_sudo)"
run_command "rm /etc/systemd/system/docker-compose.service" "$(check_sudo)"

# Entfernen von NFS-Kernel-Server-Konfiguration für EmulatorJS
run_command "systemctl stop nfs-kernel-server.service" "$(check_sudo)"
run_command "systemctl disable nfs-kernel-server.service" "$(check_sudo)"
run_command "sed -i '/\/opt\/emulatorjs *(rw,sync,no_subtree_check)/d' /etc/exports" "$(check_sudo)"
run_command "systemctl restart nfs-kernel-server.service" "$(check_sudo)"

# Entfernen von Samba-Konfiguration für EmulatorJS
run_command "systemctl stop smbd.service" "$(check_sudo)"
run_command "systemctl disable smbd.service" "$(check_sudo)"
run_command "sed -i '/\[emulatorjs\]/,/directory mask = 0775/d' /etc/samba/smb.conf" "$(check_sudo)"
run_command "systemctl restart smbd.service" "$(check_sudo)"
