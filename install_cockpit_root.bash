#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install cockpit -y

systemctl start cockpit
systemctl enable cockpit
