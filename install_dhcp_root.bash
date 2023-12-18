#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install isc-dhcp-server -y

systemctl start isc-dhcp-server.service
systemctl enable isc-dhcp-server.service
