#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
apt update
apt install mosquitto -y
apt install mosquitto-clients -y
apt clean

systemctl start mosquitto.service
systemctl enable mosquitto.service
