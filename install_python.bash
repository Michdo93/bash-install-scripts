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
        sudo "$cmd"
    else
        "$cmd"
    fi
}

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

sudo apt install python2 python2-dev -y
sudo apt install python3 python3-dev -y

sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 0
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

#sudo update-alternatives --config python

curl https://raw.githubusercontent.com/Michdo93/get-pip/main/get-pip.py -o get-pip.py
python get-pip.py

curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python3
