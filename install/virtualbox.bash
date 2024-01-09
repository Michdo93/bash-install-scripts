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

run_command "apt install virtualbox virtualbox-qt virtualbox-dkms -y" "$sudo_available"

run_command "adduser $USER vboxusers" "$sudo_available"
newgrp - vboxusers

run_command "apt install virtualbox-guest-additions-iso -y" "$sudo_available"

run_command "apt install virtualbox-guest-x11 -y" "$sudo_available"

run_command "apt install virtualbox-ext-pack -y" "$sudo_available"
