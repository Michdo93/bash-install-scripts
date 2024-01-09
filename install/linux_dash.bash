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

# Überprüfen, ob Node.js bereits installiert ist
if ! command -v node &> /dev/null; then
    # Node.js nicht gefunden, daher NVM installieren
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
    source ~/.bashrc
    nvm install --lts
    run_command "npm install pm2 -g" "$sudo_available"
fi

# Git-Repository klonen
cd /var/www/html/
run_command "git clone https://github.com/afaqurk/linux-dash.git" "$sudo_available"

# Anwendungspfad setzen
app_path="/var/www/html/linux-dash/app/server"

# Service-Datei erstellen
cat <<EOL | run_command "tee /etc/systemd/system/linux-dash.service" "$sudo_available"
[Unit]
Description=Linux Dash Server
After=network.target

[Service]
ExecStart=/usr/bin/node $app_path/index.js
WorkingDirectory=$app_path
Restart=always
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
EOL

# Service starten und aktivieren
run_command "systemctl start linux-dash.service" "$sudo_available"
run_command "systemctl enable linux-dash.service" "$sudo_available"
