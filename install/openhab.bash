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

# Install Java
run_command "apt install openjdk-17-jdk openjdk-17-jre -y" "$sudo_available"

# Setze JAVA_HOME
JAVA_HOME="/usr/lib/jvm/jdk-17"
echo "JAVA_HOME=\"$JAVA_HOME\"" | run_command "tee -a /etc/environment" "$sudo_available"

# Bearbeite die PATH-Zeile in /etc/environment
run_command 'sed -i "/^PATH=/ s/:$/:$JAVA_HOME\/bin/" /etc/environment' "$sudo_available"

# Aktualisiere die Umgebungsvariablen
source /etc/environment

# Install openHAB
curl -fsSL "https://openhab.jfrog.io/artifactory/api/gpg/key/public" | gpg --dearmor > openhab.gpg
run_command "mkdir /usr/share/keyrings" "$sudo_available"
run_command "mv openhab.gpg /usr/share/keyrings" "$sudo_available"
run_command "chmod u=rw,g=r,o=r /usr/share/keyrings/openhab.gpg" "$sudo_available"

echo 'deb [signed-by=/usr/share/keyrings/openhab.gpg] https://openhab.jfrog.io/artifactory/openhab-linuxpkg stable main' | run_command "tee /etc/apt/sources.list.d/openhab.list" "$sudo_available"

run_command "apt update" "$sudo_available"

run_command "apt install openhab openhab-addons -y" "$sudo_available"

run_command "systemctl start openhab.service" "$sudo_available"
run_command "systemctl enable openhab.service" "$sudo_available"
