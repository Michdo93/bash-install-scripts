#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt-get install -y nmap ufw

# Scannen der offenen Ports mit nmap
echo "Scanne offene Ports mit nmap..."
open_ports=$(nmap -p- --open --min-rate=1000 -T4 127.0.0.1 | grep ^[0-9] | cut -d '/' -f 1)

# Ausgabe der gefundenen offenen Ports
echo "Gefundene offene Ports: $open_ports"

sudo ufw enable

sudo ufw allow 80       # Beispiel für Port 80 (HTTP)
sudo ufw allow 22      # Beispiel für SSH

IFS=',' read -ra ports_array <<< "$open_ports"
for port in "${ports_array[@]}"; do
    sudo ufw allow $port
done

# Anzeige der aktuellen ufw-Konfiguration
echo "Aktuelle ufw-Konfiguration:"
sudo ufw status verbose > ufw_configuration.txt
cat ufw_configuration.txt

# Installiere Webmin
sudo sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
sudo apt update
sudo apt install webmin

sudo systemctl start webmin
sudo systemctl enable webmin

sudo apt install webmin-ufw

sudo ufw allow 10000
