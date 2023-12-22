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
run_command "apt install curl git wget net-tools python3-pip -y" "$sudo_available"

# Installieren von Python-Entwicklungs- und Build-Abhängigkeiten
run_command "apt install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev" "$sudo_available"

# Erstelle homeassistant-Benutzer, wenn nicht vorhanden
run_command "id -u homeassistant &>/dev/null || adduser --system homeassistant" "$sudo_available"

# Aktualisiere Paketliste
run_command "apt update" "$sudo_available"

# Installiere erforderliche Pakete
run_command "apt install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev" "$sudo_available"

# Wechsle zum Home Assistant-Benutzer und führe die Installation aus
run_command "su -s /bin/bash -c 'cd && python3 -m venv homeassistant_venv && source homeassistant_venv/bin/activate && pip install --upgrade pip && wget https://raw.githubusercontent.com/home-assistant/home-assistant/master/requirements_all.txt -O requirements_all.txt && pip install -r requirements_all.txt && pip install mysqlclient && pip install homeassistant' homeassistant" "$sudo_available"

# systemd-Service-Datei erstellen
cat <<EOL | run_command "tee /etc/systemd/system/home-assistant.service" "$sudo_available"
[Unit]
Description=Home Assistant
After=network.target

[Service]
Type=simple
User=homeassistant
ExecStart=/home/homeassistant/homeassistant_venv/bin/hass -c "/home/homeassistant/.homeassistant"

[Install]
WantedBy=multi-user.target
EOL

# systemd-Service aktivieren und starten
run_command "systemctl start home-assistant.service" "$sudo_available"
run_command "systemctl enable home-assistant.service" "$sudo_available"
