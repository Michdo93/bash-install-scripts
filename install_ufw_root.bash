#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install ufw

ufw enable
ufw allow 80       # Beispiel für Port 80 (HTTP)
ufw allow 22      # Beispiel für SSH

# Installiere Webmin
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
apt update
apt install webmin

systemctl start webmin
systemctl enable webmin

apt install webmin-ufw

ufw allow 10000
