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

run_command "sh -c 'echo deb http://download.webmin.com/download/repository sarge contrib > /etc/apt/sources.list.d/webmin.list'" "$sudo_available"
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -" "$sudo_available"

run_command "apt update" "$sudo_available"
run_command "apt install webmin -y" "$sudo_available"

run_command "systemctl start webmin" "$sudo_available"
run_command "systemctl enable webmin" "$sudo_available"
