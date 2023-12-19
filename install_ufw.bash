#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install ufw -y

sudo ufw enable
sudo ufw allow 80       # Beispiel für Port 80 (HTTP)
sudo ufw allow 22      # Beispiel für SSH

# Installiere Webmin
sudo sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
sudo apt update
sudo apt install webmin -y

sudo systemctl start webmin
sudo systemctl enable webmin

sudo apt install webmin-ufw -y

sudo ufw allow 10000
