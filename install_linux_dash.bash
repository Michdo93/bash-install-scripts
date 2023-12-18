#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

./install_nodejs.bash

cd /var/www/html/
sudo git clone https://github.com/afaqurk/linux-dash.git

cd linux-dash/app/server

npm install --production
node index.js
