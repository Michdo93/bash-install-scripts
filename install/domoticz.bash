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

run_command "apt install -y build-essential cmake git libboost-dev libboost-thread-dev libboost-system-dev libsqlite3-dev libssl-dev libcurl4-openssl-dev libusb-dev zlib1g-dev libudev-dev libreadline-dev libmosquitto-dev libmysqlclient-dev libjsoncpp-dev libwxgtk3.0-gtk3-dev" "$sudo_available"

# Domoticz unter dem Benutzer installieren
cd $HOME
run_command "git clone --recursive https://github.com/domoticz/domoticz.git" "$sudo_available"
run_command "cd domoticz" "$sudo_available"
run_command "cmake -DCMAKE_BUILD_TYPE=Release ." "$sudo_available"
run_command "make -j$(nproc)" "$sudo_available"

# Ordner erstellen, wenn er nicht existiert
run_command "mkdir -p /opt/domoticz" "$sudo_available"
run_command "chown -R $USER:$USER /opt/domoticz" "$sudo_available"

# Domoticz installieren
run_command "make install" "$sudo_available"

# systemd-Service-Datei erstellen
cat <<EOL | run_command "tee /etc/systemd/system/domoticz.service" "$sudo_available"
[Unit]
Description=Domoticz Home Automation
After=network.target

[Service]
ExecStart=/opt/domoticz/domoticz -www 8080
Restart=on-failure
User=$USER
Group=$USER
WorkingDirectory=/opt/domoticz

[Install]
WantedBy=multi-user.target
EOL

run_command "systemctl start domoticz.service" "$sudo_available"
run_command "systemctl enable domoticz.service" "$sudo_available"
