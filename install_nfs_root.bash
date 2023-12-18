#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install nfs-kernel-server -y

systemctl start nfs-kernel-server.service
systemctl enable nfs-kernel-server.service
