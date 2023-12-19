#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install dnsmasq -y

systemctl start dnsmasq
systemctl enable dnsmasq
