#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt-get install nmap ufw -y

# Scannen der offenen Ports mit nmap
echo "Scanne offene Ports mit nmap..."
open_ports=$(nmap -p- --open --min-rate=1000 -T4 127.0.0.1 | grep ^[0-9] | cut -d '/' -f 1)

# Ausgabe der gefundenen offenen Ports
echo "Gefundene offene Ports: $open_ports"

ufw enable

ufw allow 80       # Beispiel für Port 80 (HTTP)
ufw allow 22      # Beispiel für SSH

IFS=',' read -ra ports_array <<< "$open_ports"
for port in "${ports_array[@]}"; do
    ufw allow $port
done

# Anzeige der aktuellen ufw-Konfiguration
echo "Aktuelle ufw-Konfiguration:"
ufw status verbose > ufw_configuration.txt
cat ufw_configuration.txt

# Installiere Webmin
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
apt update
apt install webmin -y

systemctl start webmin
systemctl enable webmin

apt install webmin-ufw -y

ufw allow 10000
