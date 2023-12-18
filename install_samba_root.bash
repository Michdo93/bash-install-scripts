#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install samba samba-common-bin -y

systemctl start smbd.service
systemctl enable smbd.service
