#!/bin/bash

# Funktion, um zu prüfen, ob Docker installiert ist
is_docker_installed() {
    if command -v docker &> /dev/null; then
        return 0  # Docker ist installiert
    else
        return 1  # Docker ist nicht installiert
    fi
}

# Funktion, um zu prüfen, ob der homer-Container ausgeführt wird
is_homer_container_running() {
    if docker ps -q --filter "name=homer" | grep -q .; then
        return 0  # Container wird ausgeführt
    else
        return 1  # Container wird nicht ausgeführt
    fi
}

# Funktion, um zu prüfen, ob das homer-Image vorhanden ist
is_homer_image_available() {
    if docker image ls -q "homer" | grep -q .; then
        return 0  # Image ist vorhanden
    else
        return 1  # Image ist nicht vorhanden
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

# Überprüfen, ob Docker bereits installiert ist
if ! is_docker_installed; then
    echo "Docker ist nicht installiert. Skript wird beendet." >&2
    exit 1
fi

# Überprüfen, ob der homer-Container ausgeführt wird
if is_homer_container_running; then
    # Container stoppen
    run_command "docker stop homer" "$(check_sudo)"
fi

# Überprüfen, ob das homer-Image vorhanden ist
if is_homer_image_available; then
    # Container löschen
    run_command "docker rm homer" "$(check_sudo)"

    # Image löschen
    run_command "docker rmi homer" "$(check_sudo)"
else
    echo "Das homer-Image ist nicht vorhanden." >&2
fi
