#!/bin/bash

# Verzeichnis für Docker-Konfigurationen
config_dir="/opt/docker/configs"
container_dir="/opt/docker/containers"

# Benutzername
smb_user=$USER

# Samba-Passwort
smb_password="Samba"

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

# Überprüfen, ob Samba bereits installiert ist
if command -v smbd &> /dev/null; then
    echo "Samba ist bereits installiert."
else
    # Installieren von Samba
    sudo_available=$(check_sudo)
    run_command "apt update" "$sudo_available"
    run_command "apt install samba samba-common-bin -y" "$sudo_available"
fi

# Samba-Konfiguration
smb_conf="/etc/samba/smb.conf"
if [ -f "$smb_conf" ]; then
    # Backup der aktuellen Konfigurationsdatei erstellen
    run_command "cp $smb_conf $smb_conf.bak" "$sudo_available"
fi

# Samba-Freigaben hinzufügen
cat >> "$smb_conf" <<EOL

[$config_dir]
   comment = Docker Configs
   path = $config_dir
   browseable = yes
   read only = no
   guest ok = no
   create mask = 0755
   force user = $smb_user

[$container_dir]
   comment = Docker Containers
   path = $container_dir
   browseable = yes
   read only = no
   guest ok = no
   create mask = 0755
   force user = $smb_user
EOL

# Samba-Benutzer hinzufügen
echo -e "$smb_password\n$smb_password" | run_command "smbpasswd -a $smb_user" "$sudo_available"

# Samba-Service starten und aktivieren
run_command "systemctl start smbd.service" "$sudo_available"
run_command "systemctl enable smbd.service" "$sudo_available"

echo "Samba wurde erfolgreich installiert und konfiguriert."
