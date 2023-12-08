#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install isc-dhcp-server -y

sudo systemctl start isc-dhcp-server.service
sudo systemctl enable isc-dhcp-server.service
