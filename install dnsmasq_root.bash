#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install dnsmasq

systemctl start dnsmasq
systemctl enable dnsmasq
