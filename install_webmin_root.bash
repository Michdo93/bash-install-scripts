#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

apt update
apt install webmin -y

systemctl start webmin
systemctl enable webmin
