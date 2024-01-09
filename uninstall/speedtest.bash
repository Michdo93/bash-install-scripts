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

# Deinstallieren von Speedtest CLI
run_command "apt remove --purge speedtest -y" "$sudo_available"

# Löschen des Speedtest Python-Skripts
run_command "rm /home/$USER/speedtest.py" "$sudo_available"

# Entfernen des Eintrags in der Crontab
run_command "sed -i '/speedtest.py/d' /etc/crontab" "$sudo_available"

# Überprüfen, ob influxdb-client bereits installiert ist
if command -v influx &> /dev/null; then
    # Befehle zum Löschen der InfluxDB-Datenbank und des Benutzers
    INFLUXDB_HOST="localhost"
    INFLUXDB_PORT="8086"
    INFLUXDB_USERNAME="admin"
    INFLUXDB_PASSWORD="influxdb"

    COMMANDS=("DROP DATABASE internetspeed" "DROP USER $INFLUXDB_USERNAME" "quit")

    # Verbinde dich mit InfluxDB und führe die Befehle aus
    for COMMAND in "${COMMANDS[@]}"; do
        echo "$COMMAND" | influx -host "$INFLUXDB_HOST" -port "$INFLUXDB_PORT" -token "$INFLUXDB_USERNAME:$INFLUXDB_PASSWORD" -organization "influxdb"
    done
fi

# Entfernen von Paketlisten und Aktualisieren des Systems
run_command "apt autoremove -y" "$sudo_available"
run_command "apt clean" "$sudo_available"
run_command "apt update" "$sudo_available"

echo "Deinstallation abgeschlossen."
