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

# Add Docker's official GPG key:
run_command "apt update" "$sudo_available"
run_command "apt install ca-certificates curl gnupg -y" "$sudo_available"
run_command "install -m 0755 -d /etc/apt/keyrings" "$sudo_available"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
run_command "chmod a+r /etc/apt/keyrings/docker.gpg" "$sudo_available"

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  run_command "tee /etc/apt/sources.list.d/docker.list > /dev/null" "$sudo_available"
run_command "apt update" "$sudo_available"

run_command "apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y" "$sudo_available"

run_command "groupadd docker" "$sudo_available"
run_command "usermod -aG docker $USER" "$sudo_available"

run_command "systemctl start docker.service" "$sudo_available"
run_command "systemctl enable docker.service" "$sudo_available"
run_command "systemctl start containerd.service" "$sudo_available"
run_command "systemctl enable containerd.service" "$sudo_available"
