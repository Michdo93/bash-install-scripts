#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -

sudo apt update
sudo apt install webmin

sudo systemctl start webmin
sudo systemctl enable webmin
