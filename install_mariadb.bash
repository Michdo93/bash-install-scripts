#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install mariadb-server -y
sudo mysql_secure_installation

sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service