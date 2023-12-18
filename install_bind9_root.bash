#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install bind9 -y

systemctl start bind9.service
systemctl enable bind9.service
