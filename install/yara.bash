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

run_command "apt install automake libtool make gcc pkg-config flex bison libssl-dev -y" "$sudo_available"

cd /opt
wget https://github.com/VirusTotal/yara/archive/refs/tags/v4.4.0.tar.gz
tar -zxf v4.4.0.tar.gz
rm -r v4.4.0.tar.gz
cd yara-4.4.0
./bootstrap.sh
./configure
make
run_command "make install" "$sudo_available"

run_command "ln -s /usr/local/lib/libyara.so /usr/lib/libyara.so" "$sudo_available"
