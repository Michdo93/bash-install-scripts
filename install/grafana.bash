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

run_command "apt install -y software-properties-common" "$sudo_available"
run_command "add-apt-repository \"deb https://packages.grafana.com/oss/deb stable main\"" "$sudo_available"
wget -q -O - https://packages.grafana.com/gpg.key | run_command "sudo apt-key add -" "$sudo_available"
run_command "apt update" "$sudo_available"
run_command "apt install -y grafana" "$sudo_available"

# Grafana-Dienst starten und aktivieren
run_command "systemctl start grafana-server" "$sudo_available"
run_command "systemctl enable grafana-server" "$sudo_available"
