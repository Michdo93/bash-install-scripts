#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install cockpit

systemctl start cockpit
systemctl enable cockpit
