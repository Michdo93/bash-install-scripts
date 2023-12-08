#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt-get install clamav clamav-freshclam -y
sudo apt-get install clamav-docs -y

echo '10 3 * * * root /usr/bin/clamscan -ir / | /usr/bin/grep FOUND >> /home/ubuntu/clamavinfected.txt' | sudo tee -a /etc/crontab
echo '@reboot root /usr/bin/clamscan -ir / | /usr/bin/grep FOUND >> /home/ubuntu/clamavinfected.txt' | sudo tee -a /etc/crontab