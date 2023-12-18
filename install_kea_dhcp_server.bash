#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install kea-dhcp4-server -y

sudo systemctl start kea-dhcp4-server
sudo systemctl enable kea-dhcp4-server
