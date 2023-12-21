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

run_command "apt install python3-pip -y" "$sudo_available"

# Installieren von Python-Entwicklungs- und Build-Abhängigkeiten
run_command "apt install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev" "$sudo_available"

# Als root fortfahren
run_command "su" "$sudo_available"

# Aktualisiere Paketliste
apt update

# Installiere erforderliche Pakete
apt install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev

# Zum Home Assistant-Benutzer wechseln
run_command "su - homeassistant" "$sudo_available"

# Wechsle zum Home Assistant-Verzeichnis und erstelle ein virtuelles Umgebung
cd /home/homeassistant/
python3 -m venv homeassistant_venv
source /home/homeassistant/homeassistant_venv/bin/activate
pip install --upgrade pip

# Herunterladen der Anforderungen
wget https://raw.githubusercontent.com/home-assistant/home-assistant/master/requirements_all.txt -O requirements_all.txt

# Installation der Anforderungen (dies kann Stunden dauern und Sie müssen möglicherweise fehlgeschlagene Abhängigkeiten manuell installieren)
pip install -r requirements_all.txt
pip install mysqlclient
pip install homeassistant

# Zurück zu root wechseln
exit

# Bearbeiten der systemd-Service-Datei für das neue Virtualenv
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
