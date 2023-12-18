#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install isc-dhcp-server

systemctl start isc-dhcp-server
systemctl enable isc-dhcp-server
