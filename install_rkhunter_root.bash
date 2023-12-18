#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt-get install rkhunter -y
apt-get install mailutils -y

echo '10 3 * * * root /usr/bin/rkhunter --cronjob' | tee -a /etc/crontab
echo '@reboot root /usr/bin/rkhunter -c' | tee -a /etc/crontab
