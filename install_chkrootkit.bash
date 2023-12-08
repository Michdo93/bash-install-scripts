#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt-get install chkrootkit -y

echo '10 3 * * * root /usr/bin/chkrootkit' | sudo tee -a /etc/crontab
echo '@reboot root /usr/bin/chkrootkit' | sudo tee -a /etc/crontab