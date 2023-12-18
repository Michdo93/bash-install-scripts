#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
apt-get update
apt-get install mosquitto -y
apt-get install mosquitto-clients -y
apt clean

systemctl start mosquitto.service
systemctl enable mosquitto.service
