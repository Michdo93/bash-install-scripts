#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install dropbear -y

sudo systemctl start dropbear.service
sudo systemctl enable dropbear.service
