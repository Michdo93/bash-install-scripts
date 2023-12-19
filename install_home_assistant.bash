#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

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
