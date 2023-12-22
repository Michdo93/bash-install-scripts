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

# Node.js, NVM und PM2 deinstallieren
run_command "npm uninstall -g pm2" "$sudo_available"
run_command "nvm deactivate" "$sudo_available"
run_command "nvm uninstall --lts" "$sudo_available"
run_command "rm -rf ~/.nvm" "$sudo_available"

# Abschließende Aufräumarbeiten (optional)
run_command "apt remove --purge nodejs npm -y" "$sudo_available"
run_command "apt autoremove -y" "$sudo_available"
run_command "apt clean" "$sudo_available"
