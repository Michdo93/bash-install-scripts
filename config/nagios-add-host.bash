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

nagios_config_dir="/usr/local/nagios/etc"
template_file="$nagios_config_dir/template.cfg"

# Überprüfen, ob das Template existiert
if [ ! -e "$template_file" ]; then
    echo "Das Template-Datei $template_file existiert nicht."
    exit 1
fi

# Aufforderungen für Benutzereingaben
read -p "Geben Sie den Hostnamen ein: " hostname
read -p "Geben Sie die IP-Adresse ein: " ip_address

# Dateinamen erstellen
config_file="$nagios_config_dir/$hostname.cfg"

# Kopieren des Templates in die neue Datei
cp "$template_file" "$config_file"

# Ersetzen der Platzhalter in der neuen Datei
sed -i "s/\$HOSTNAME\$/$hostname/g" "$config_file"
sed -i "s/\$IP_ADDRESS\$/$ip_address/g" "$config_file"

echo "Konfigurationsdatei erfolgreich erstellt: $config_file"

sudo_available=$(check_sudo)
run_command "systemctl restart nagios" "$sudo_available"
