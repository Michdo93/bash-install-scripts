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

# Pi-hole installieren und Adlisten herunterladen
install_pihole() {
    run_command "wget -O basic-install.sh https://install.pi-hole.net" "$sudo_available"
    run_command "bash basic-install.sh" "$sudo_available"

    # Pfad zu Pi-hole-Adlisten
    adlists_dir="/etc/pihole"

    # Array mit URLs zu den Adlisten
    adlist_urls=(
        # ... (Deine Adlisten-URLs hier)
    )

    # Durchlaufe das Array und lade jede Adliste herunter
    for adlist_url in "${adlist_urls[@]}"; do
        # Extrahiere den Dateinamen aus der URL
        adlist_file=$(basename "$adlist_url")
        # Lade die Adliste herunter
        if curl -sSL "$adlist_url" > "$adlists_dir/$adlist_file"; then
            echo "Adliste $adlist_file erfolgreich heruntergeladen."
        else
            echo "Fehler beim Herunterladen von Adliste $adlist_file."
        fi
    done

    # Aktualisiere Pi-hole, um die neuen Adlisten zu berücksichtigen
    run_command "pihole -g" "$sudo_available"
}

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

# Pi-hole installieren und Adlisten herunterladen
install_pihole

cd /opt/
run_command "git clone https://github.com/anudeepND/whitelist.git" "$sudo_available"
run_command "python3 whitelist/scripts/whitelist.py" "$sudo_available"

echo '0 23 * * 7 root /opt/whitelist/scripts/whitelist.py' | run_command "tee -a /etc/crontab" "$sudo_available"

run_command "pihole -w \
accounts.google.com \
bit.ly \
doodle.com \
ec-ns.sascdn.com \
login.aliexpress.com \
paypal.com \
pinterest.com \
s.shopify.com \
sharepoint.com \
sourceforge.net \
twitter.com \
v.shopify.com \
versus.com \
www.paypalobjects.com" "$sudo_available"
