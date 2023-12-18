#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install python2 python2-dev -y
sudo apt-get install python3 python3-dev -y

sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 2

sudo update-alternatives --config python

curl https://raw.githubusercontent.com/Michdo93/get-pip/main/get-pip.py -o get-pip.py
python get-pip.py

curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python3
