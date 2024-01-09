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

# Stoppen und Deaktivieren von Docker-Diensten (falls gestartet)
run_command "systemctl stop docker.service" "$(check_sudo)"
run_command "systemctl disable docker.service" "$(check_sudo)"
run_command "systemctl stop containerd.service" "$(check_sudo)"
run_command "systemctl disable containerd.service" "$(check_sudo)"

# Optionale Deinstallation von Docker
run_command "apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y" "$(check_sudo)"

# Rückgängig machen der Gruppen- und Benutzermodifikationen
run_command "gpasswd -d $USER docker" "$(check_sudo)"
run_command "groupdel docker" "$(check_sudo)"
