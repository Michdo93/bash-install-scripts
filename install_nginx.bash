#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install nginx -y
sudo systemctl start nginx.service
sudo systemctl enable nginx.service