#!/bin/bash

# Funktion, um zu prüfen, ob sudo verfügbar ist
check_sudo() {
    if command -v sudo &> /dev/null; then
        echo "sudo"
    else
        echo ""
    fi
}

# Funktion zum Ausführen von Befehlen mit oder ohne sudo
run_command() {
    local cmd="$1"
    local sudo_available="$2"

    if [ -n "$sudo_available" ]; then
        sudo "$cmd"
    else
        "$cmd"
    fi
}

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

sudo apt-get install -y nmap ufw

# Scannen der offenen Ports mit nmap
echo "Scanne offene Ports mit nmap..."
open_ports=$(nmap -p- --open --min-rate=1000 -T4 127.0.0.1 | grep ^[0-9] | cut -d '/' -f 1)

# Ausgabe der gefundenen offenen Ports
echo "Gefundene offene Ports: $open_ports"

sudo ufw enable

sudo ufw allow 80       # Beispiel für Port 80 (HTTP)
sudo ufw allow 22      # Beispiel für SSH

IFS=',' read -ra ports_array <<< "$open_ports"
for port in "${ports_array[@]}"; do
    sudo ufw allow $port
done

# Anzeige der aktuellen ufw-Konfiguration
echo "Aktuelle ufw-Konfiguration:"
sudo ufw status verbose > ufw_configuration.txt
cat ufw_configuration.txt

# Installiere Webmin
sudo sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
sudo apt update
sudo apt install webmin -y

sudo systemctl start webmin
sudo systemctl enable webmin

sudo apt install webmin-ufw -y

sudo ufw allow 10000
