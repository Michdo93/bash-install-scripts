#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt-get install rkhunter -y
sudo apt-get install mailutils -y

echo '10 3 * * * root /usr/bin/rkhunter --cronjob' | sudo tee -a /etc/crontab
echo '@reboot root /usr/bin/rkhunter -c' | sudo tee -a /etc/crontab