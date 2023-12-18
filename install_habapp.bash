#!/bin/bash

# Schritte für die Installation von HABApp
cd /opt
python3 -m venv habapp
cd habapp
source bin/activate
python3 -m pip install --upgrade pip setuptools
python3 -m pip install habapp

# HABApp konfigurieren und starten
habapp --config /etc/openhab/habapp

# systemd-Service-Datei erstellen
cat <<EOL | sudo tee /etc/systemd/system/habapp.service
[Unit]
Description=HABApp
Documentation=https://habapp.readthedocs.io
Requires=openhab.service
After=openhab.service
BindsTo=openhab.service
PartOf=openhab.service

[Service]
Type=simple
User=openhab
Group=openhab
UMask=002
Environment=LD_LIBRARY_PATH=/home/<user>/catkin_ws/devel/lib:/opt/ros/<ros_distro>/lib
ExecStart=/bin/bash -c 'source /etc/environment; /usr/bin/python3 /opt/habapp/bin/habapp -c /etc/openhab/habapp'
Restart=on-failure
RestartSec=30s

[Install]
WantedBy=openhab.service
EOL

# systemd-Service aktivieren und starten
sudo systemctl enable habapp.service
sudo systemctl start habapp.service
