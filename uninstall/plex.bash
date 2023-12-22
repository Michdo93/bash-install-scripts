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

# Plex Media Server deinstallieren
sudo_available=$(check_sudo)
run_command "systemctl stop plexmediaserver.service" "$sudo_available"
run_command "systemctl disable plexmediaserver.service" "$sudo_available"
run_command "apt remove --purge plexmediaserver -y" "$sudo_available"
run_command "rm -f /etc/apt/sources.list.d/plexmediaserver.list" "$sudo_available"
run_command "apt-key del 6C19886DCB281CF2" "$sudo_available"

plex_media_dir="/opt/plexmedia"
run_command "rm -rf $plex_media_dir" "$sudo_available"

echo "Plex Media Server wurde erfolgreich deinstalliert."
