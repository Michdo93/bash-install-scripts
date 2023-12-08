#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install bind9 -y

sudo systemctl start bind9.service
sudo systemctl enable bind9.service
