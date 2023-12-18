#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install openssh-server openssh-client -y

sudo systemctl start ssh
sudo systemctl enable ssh
