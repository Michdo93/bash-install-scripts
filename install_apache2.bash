#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install apache2 -y
sudo systemctl start apache2.service
sudo systemctl enable apache2.service