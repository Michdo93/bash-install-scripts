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

./install_python.bash

# As root
sudo su
apt update
apt install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev

# Switch to Home Assistant User
sudo su - homeassistant
cd /home/homeassistant/
python3 -m venv homeassistant_venv
source /home/homeassistant/homeassistant_venv/bin/activate
pip install --upgrade pip
wget https://raw.githubusercontent.com/home-assistant/home-assistant/master/requirements_all.txt -O requirements_all.txt
# This takes hours to finish and you may need to install additional failed dependencies if you get errors
pip install -r requirements_all.txt
pip install mysqlclient
pip install homeassistant
# Go back to root
exit

# edit systemd service unit for new virtualenv
cat <<EOL | sudo tee /etc/systemd/system/home-assistant.service
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

sudo systemctl start home-assistant.service
sudo systemctl enable home-assistant.service
