#!/bin/bash

# Verzeichnis für Docker-Konfigurationen
config_dir="/opt/docker/configs"
container_dir="/opt/docker/containers"

# Service-Datei entfernen
service_file="/etc/systemd/system/adguardhome-sync.service"
sudo systemctl stop adguardhome-sync.service
sudo systemctl disable adguardhome-sync.service
sudo rm -f "$service_file"
sudo systemctl daemon-reload

# Docker-Compose-Datei und Volumes entfernen
compose_file="$config_dir/adguardhome-sync.yml"
if [ -f "$compose_file" ]; then
    docker-compose -f "$compose_file" down
    rm -f "$compose_file"
fi
rm -rf "$container_dir/adguardhome-sync"

# Optional: Container stoppen und entfernen
docker stop adguardhome-sync
docker rm adguardhome-sync

echo "Deinstallation abgeschlossen."
