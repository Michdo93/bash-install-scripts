#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install cockpit

sudo systemctl start cockpit
sudo systemctl enable cockpit
