#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt-get install virtualbox virtualbox-qt virtualbox-dkms -y

sudo adduser $USER vboxusers
newgrp - vboxusers

sudo apt-get install virtualbox-guest-additions-iso -y

sudo apt-get install virtualbox-guest-x11 -y

sudo apt-get install virtualbox-ext-pack -y
