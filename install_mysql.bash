#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install mysql-server -y

sudo mysql_secure_installation

sudo systemctl start mysql.service
sudo systemctl enable mysql.service
