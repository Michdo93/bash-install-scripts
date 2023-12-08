#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install nfs-kernel-server -y
sudo systemctl start nfs-kernel-server.service
sudo systemctl enable nfs-kernel-server.service
