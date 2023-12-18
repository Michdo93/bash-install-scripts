#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

curl -s https://packagecloud.io/install/repositories/qxip/sipcapture/script.deb.sh | sudo bash
