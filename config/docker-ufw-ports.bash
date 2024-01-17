#!/bin/bash

# Funktion zum Überprüfen, ob sudo verfügbar ist
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

# Überprüfen, ob ufw installiert ist
if ! command -v ufw &> /dev/null; then
    sudo_available=$(check_sudo)
    run_command "apt update" "$sudo_available"
    run_command "apt install ufw -y" "$sudo_available"
fi

# Überprüfen, ob ufw aktiviert ist
if ! ufw status | grep -q "Status: active"; then
    sudo_available=$(check_sudo)
    run_command "ufw enable" "$sudo_available"
fi

# Durchsuchen der Docker-Container und Ermitteln der verwendeten Ports
docker_ports=$(docker ps --format "{{.Ports}}" | awk -F '->' '{print $2}' | cut -d '/' -f 1)

# Ermitteln der eindeutigen Ports
unique_ports=$(echo "$docker_ports" | tr ',' '\n' | sort -u)

# Erlauben der Ports in ufw
for port in $unique_ports; do
    run_command "ufw allow $port" "$(check_sudo)"
done

# Aktualisieren der ufw-Regeln
run_command "ufw reload" "$(check_sudo)"

echo "Docker-Ports wurden erfolgreich in ufw erlaubt."
