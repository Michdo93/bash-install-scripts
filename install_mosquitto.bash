#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
sudo apt update
sudo apt install mosquitto -y
sudo apt install mosquitto-clients -y
sudo apt clean

sudo systemctl start mosquitto.service
sudo systemctl enable mosquitto.service
