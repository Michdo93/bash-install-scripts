#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt-get install chkrootkit -y

echo '10 3 * * * root /usr/bin/chkrootkit' | tee -a /etc/crontab
echo '@reboot root /usr/bin/chkrootkit' | tee -a /etc/crontab
