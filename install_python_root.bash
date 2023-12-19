#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

apt install python2 python2-dev
apt install python3 python3-dev

update-alternatives --install /usr/bin/python python /usr/bin/python2 1
update-alternatives --install /usr/bin/python python /usr/bin/python3 2

update-alternatives --config python

curl https://raw.githubusercontent.com/Michdo93/get-pip/main/get-pip.py -o get-pip.py
python get-pip.py

curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python3
