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

echo $sudo_available

run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

run_command "echo -e '\n' | apt-add-repository ppa:mosquitto-dev/mosquitto-ppa" "$sudo_available"
run_command "apt update" "$sudo_available"
run_command "apt install mosquitto -y" "$sudo_available"
run_command "apt install mosquitto-clients -y" "$sudo_available"
run_command "apt clean" "$sudo_available"

run_command "systemctl start mosquitto.service" "$sudo_available"
run_command "systemctl enable mosquitto.service" "$sudo_available"
