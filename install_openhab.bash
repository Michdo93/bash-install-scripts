#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

# Install Java
sudo apt install openjdk-17-jdk openjdk-17-jre -y

# Setze JAVA_HOME
echo 'JAVA_HOME="/usr/lib/jvm/jdk-17"' | sudo tee -a /etc/environment

# Ergänze PATH mit JAVA_HOME/bin
echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/environment

# Aktualisiere die Umgebungsvariablen
source /etc/environment

# Install openHAB
curl -fsSL "https://openhab.jfrog.io/artifactory/api/gpg/key/public" | gpg --dearmor > openhab.gpg
sudo mkdir /usr/share/keyrings
sudo mv openhab.gpg /usr/share/keyrings
sudo chmod u=rw,g=r,o=r /usr/share/keyrings/openhab.gpg

echo 'deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main' | sudo tee /etc/apt/sources.list.d/openhab.list

sudo apt update

sudo apt install openhab openhab-addons -y

sudo systemctl start openhab.service
sudo systemctl enable openhab.service