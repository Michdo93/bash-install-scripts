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
        sudo $cmd
    else
        $cmd
    fi
}

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

run_command "apt install -y nmap ufw" "$sudo_available"

# Scannen der offenen Ports mit nmap
echo "Scanne offene Ports mit nmap..."
open_ports=$(nmap -p- --open --min-rate=1000 -T4 127.0.0.1 | grep ^[0-9] | cut -d '/' -f 1)

# Ausgabe der gefundenen offenen Ports
echo "Gefundene offene Ports: $open_ports"

run_command "ufw enable" "$sudo_available"

run_command "ufw allow 80" "$sudo_available"
run_command "ufw allow 22" "$sudo_available"

IFS=',' read -ra ports_array <<< "$open_ports"
for port in "${ports_array[@]}"; do
    run_command "ufw allow $port" "$sudo_available"  # Hier war das schließende Anführungszeichen vergessen
done

# Anzeige der aktuellen ufw-Konfiguration
echo "Aktuelle ufw-Konfiguration:"
run_command "ufw status verbose > ufw_configuration.txt" "$sudo_available"
cat ufw_configuration.txt

# Installiere Webmin
run_command "sh -c 'echo \"deb http://download.webmin.com/download/repository sarge contrib\" > /etc/apt/sources.list.d/webmin.list'"
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
run_command "apt update" "$sudo_available"
run_command "apt install webmin -y" "$sudo_available"

run_command "systemctl start webmin" "$sudo_available"
run_command "systemctl enable webmin" "$sudo_available"

run_command "apt install webmin-ufw -y" "$sudo_available"

run_command "ufw allow 10000" "$sudo_available"
