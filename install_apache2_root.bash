#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install apache2 -y
systemctl start apache2.service
systemctl enable apache2.service
