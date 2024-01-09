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
run_command "apt install curl git wget net-tools python3-pip python3-venv -y" "$sudo_available"

# Überprüfen, ob openHAB installiert ist
if ! command -v openhab &> /dev/null; then
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
fi

# Schritte für die Installation von HABApp
HABAPP_DIR="/opt/habapp"

# Hier wird sichergestellt, dass das Verzeichnis existiert und für den openhab-Benutzer zugänglich ist
run_command "mkdir -p $HABAPP_DIR" "$sudo_available"

# Wechseln zum HABApp-Verzeichnis und Installation in einem Virtual Environment
cd $HABAPP_DIR
run_command "sudo python3 -m venv env" "$sudo_available"
source env/bin/activate
python3 -m pip install --upgrade pip setuptools
python3 -m pip install habapp

run_command "chown -R openhab:openhab $HABAPP_DIR" "$sudo_available"

# HABApp konfigurieren und starten
run_command "habapp --config /etc/openhab/habapp" "$sudo_available"

# systemd-Service-Datei erstellen
cat <<EOL | run_command "tee /etc/systemd/system/habapp.service" "$sudo_available"
[Unit]
Description=HABApp
Documentation=https://habapp.readthedocs.io
Requires=openhab.service
After=openhab.service
BindsTo=openhab.service
PartOf=openhab.service

[Service]
Type=simple
User=openhab
Group=openhab
UMask=002
Environment=LD_LIBRARY_PATH=/home/<user>/catkin_ws/devel/lib:/opt/ros/<ros_distro>/lib
ExecStart=/bin/bash -c 'source /etc/environment && /opt/habapp/env/bin/habapp -c /etc/openhab/habapp'
Restart=on-failure
RestartSec=30s

[Install]
WantedBy=openhab.service
EOL

# systemd-Service aktivieren und starten
run_command "systemctl enable habapp.service" "$sudo_available"
run_command "systemctl start habapp.service" "$sudo_available"
