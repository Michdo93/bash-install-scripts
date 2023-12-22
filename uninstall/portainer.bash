#!/bin/bash

# Funktion, um zu prüfen, ob Docker installiert ist
is_docker_installed() {
    if command -v docker &> /dev/null; then
        return 0  # Docker ist installiert
    else
        return 1  # Docker ist nicht installiert
    fi
}

# Funktion, um zu prüfen, ob der Portainer-Container läuft
is_portainer_running() {
    if docker ps -q --filter "name=portainer" | grep -q .; then
        return 0  # Portainer-Container läuft
    else
        return 1  # Portainer-Container läuft nicht
    fi
}

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

# Überprüfen, ob Docker installiert ist
if ! is_docker_installed; then
    echo "Docker ist nicht installiert. Beende die Deinstallation."
    exit 1
fi

# Überprüfen, ob der Portainer-Container läuft
if is_portainer_running; then
    echo "Stoppe und entferne den laufenden Portainer-Container."
    run_command "docker stop portainer" "$sudo_available"
    run_command "docker rm portainer" "$sudo_available"
else
    echo "Der Portainer-Container ist nicht aktiv. Fortsetzen..."
fi

# Lösche das Portainer-Image
echo "Entferne das Portainer-Image."
run_command "docker rmi portainer/portainer:latest" "$sudo_available"

echo "Portainer wurde erfolgreich deinstalliert."
