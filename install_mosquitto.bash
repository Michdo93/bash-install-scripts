#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
sudo apt-get update
sudo apt-get install mosquitto -y
sudo apt-get install mosquitto-clients -y
sudo apt clean

sudo systemctl start mosquitto.service
sudo systemctl enable mosquitto.service
