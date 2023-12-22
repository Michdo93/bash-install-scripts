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

run_command "apt install ca-certificates apt-transport-https software-properties-common lsb-release -y" "$sudo_available"
run_command "add-apt-repository ppa:team-xbmc/ppa -y" "$sudo_available"

run_command "apt update" "$sudo_available"

run_command "apt install kodi kodi-bin -y" "$sudo_available"

cat <<EOL > "/etc/systemd/system/kodi.service"
[Unit]
Description = Kodi Media Center
After = remote-fs.target network-online.target
Wants = network-online.target

[Service]
User = $USER
Group = $USER
Type = simple
ExecStart = /usr/bin/kodi-standalone
Restart = on-abort
RestartSec = 5

[Install]
WantedBy = multi-user.target
EOL

run_command "systemctl start kodi.service" "$sudo_available"
run_command "systemctl enable kodi.service" "$sudo_available"
