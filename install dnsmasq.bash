#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install dnsmasq

sudo systemctl start dnsmasq
sudo systemctl enable dnsmasq
