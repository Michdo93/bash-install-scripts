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

# Funktion zum Suchen der Nagios-IP
find_nagios_ip() {
    local local_ip="$1"
    local network_prefix="$(echo "$local_ip" | awk -F'.' '{print $1"."$2"."$3"."}')"
    
    for i in {1..254}; do
        ip_to_check="$network_prefix$i"
        if curl --output /dev/null --silent --head --fail "$ip_to_check/nagios/"; then
            echo "$ip_to_check"
            break
        fi
    done
}

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

run_command "apt install nagios-nrpe-server monitoring-plugins -y" "$sudo_available"

ip_address="$(hostname -I | awk '{print $1}')"

echo "server_address=$ip_address" | tee -a "/etc/nagios/nrpe.cfg"

# Ermitteln der Nagios-IP-Adresse
nagios_ip=$(find_nagios_ip "$ip_address")

if [ -n "$nagios_ip" ]; then
    # Hinzufügen der allowed_hosts zu nrpe.cfg
    echo "allowed_hosts=127.0.0.1,::1,$nagios_ip" | tee -a "/etc/nagios/nrpe.cfg"
    
    echo "allowed_hosts erfolgreich hinzugefügt."
else
    echo "Nagios-IP-Adresse konnte nicht ermittelt werden."
fi

echo "command[check_root]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /" | tee -a "/etc/nagios/nrpe_local.cfg"
echo "command[check_ping]=/usr/lib/nagios/plugins/check_ping -H $ip_address -w 100.0,20% -c 500.0,60% -p 5" | tee -a "/etc/nagios/nrpe_local.cfg"
echo "command[check_ssh]=/usr/lib/nagios/plugins/check_ssh -4 $ip_address" | tee -a "/etc/nagios/nrpe_local.cfg"
echo "command[check_http]=/usr/lib/nagios/plugins/check_http -I $ip_address" | tee -a "/etc/nagios/nrpe_local.cfg"
echo "command[check_apt]=/usr/lib/nagios/plugins/check_apt" | tee -a "/etc/nagios/nrpe_local.cfg"

run_command "systemctl restart nagios-nrpe-server" "$sudo_available"
run_command "systemctl enable nagios-nrpe-server" "$sudo_available"

