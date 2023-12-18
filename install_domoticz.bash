#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install -y build-essential cmake git libboost-dev libboost-thread-dev libboost-system-dev libsqlite3-dev libssl-dev libcurl4-openssl-dev libusb-dev zlib1g-dev libudev-dev libreadline-dev libmosquitto-dev libmysqlclient-dev libjsoncpp-dev libwxgtk3.0-gtk3-dev

git clone --recursive https://github.com/domoticz/domoticz.git
cd domoticz
cmake -DCMAKE_BUILD_TYPE=Release .
make -j$(nproc)

sudo make install

# systemd-Service-Datei erstellen
cat <<EOL | sudo tee /etc/systemd/system/domoticz.service
[Unit]
Description=Domoticz Home Automation
After=network.target

[Service]
ExecStart=/opt/domoticz/domoticz -www 8080
Restart=on-failure
User=root
Group=root
WorkingDirectory=/opt/domoticz

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl start domoticz.service
sudo systemctl enable domoticz.service
