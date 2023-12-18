#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install kea-dhcp4-server -y

systemctl start kea-dhcp4-server
systemctl enable kea-dhcp4-server
