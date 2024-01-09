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

# Pi-hole deinstallieren
uninstall_pihole() {
    run_command "pihole uninstall" "$sudo_available"
}

# Entferne Pi-hole-Adlisten und Konfiguration
remove_pihole_config() {
    run_command "rm -rf /etc/pihole" "$sudo_available"
}

# Aktualisiere und entferne installierte Pakete
cleanup_packages() {
    run_command "apt remove --purge -y pihole" "$sudo_available"
    run_command "apt autoremove -y" "$sudo_available"
}

# Deinstalliere Pi-hole
sudo_available=$(check_sudo)
uninstall_pihole

# Entferne Pi-hole-Adlisten und Konfiguration
remove_pihole_config

# Aktualisiere und entferne installierte Pakete
cleanup_packages

# Entferne das Verzeichnis, in dem das Skript gespeichert wurde (optional)
current_directory=$(pwd)
run_command "rm -rf $current_directory" ""

echo "Pi-hole wurde erfolgreich deinstalliert."
