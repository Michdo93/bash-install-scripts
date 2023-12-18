#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt-get install clamav clamav-freshclam -y
apt-get install clamav-docs -y

echo '10 3 * * * root /usr/bin/clamscan -ir / | /usr/bin/grep FOUND >> /home/ubuntu/clamavinfected.txt' | tee -a /etc/crontab
echo '@reboot root /usr/bin/clamscan -ir / | /usr/bin/grep FOUND >> /home/ubuntu/clamavinfected.txt' | tee -a /etc/crontab
