#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install automake libtool make gcc pkg-config flex bison libssl-dev -y

cd /opt
wget https://github.com/VirusTotal/yara/archive/refs/tags/v4.4.0.tar.gz
tar -zxf v4.4.0.tar.gz
rm -r v4.4.0.tar.gz
cd yara-4.4.0
./bootstrap.sh
./configure
make
sudo make install

sudo ln -s /usr/local/lib/libyara.so /usr/lib/libyara.so
