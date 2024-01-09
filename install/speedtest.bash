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

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools apt-transport-https gnupg1 dirmngr lsb-release -y" "$sudo_available"

# Installieren von Speedtest CLI
curl -L https://packagecloud.io/ookla/speedtest-cli/gpgkey | gpg --dearmor | run_command "tee /usr/share/keyrings/speedtestcli-archive-keyring.gpg >/dev/null" "$sudo_available"

echo "deb [signed-by=/usr/share/keyrings/speedtestcli-archive-keyring.gpg] https://packagecloud.io/ookla/speedtest-cli/debian/ $(lsb_release -cs) main" | run_command "tee /etc/apt/sources.list.d/speedtest.list" "$sudo_available"

run_command "apt update" "$sudo_available"
run_command "apt install speedtest -y" "$sudo_available"

# Speedtest Python-Skript erstellen
cat <<EOL | run_command "tee /home/$USER/speedtest.py" "$sudo_available"
import re
import subprocess
from influxdb import InfluxDBClient

response = subprocess.Popen('/usr/bin/speedtest --accept-license --accept-gdpr', shell=True, stdout=subprocess.PIPE).stdout.read().decode('utf-8')

ping = re.search('Latency:\s+(.*?)\s', response, re.MULTILINE)
download = re.search('Download:\s+(.*?)\s', response, re.MULTILINE)
upload = re.search('Upload:\s+(.*?)\s', response, re.MULTILINE)
jitter = re.search('Latency:.*?jitter:\s+(.*?)ms', response, re.MULTILINE)

ping = ping.group(1)
download = download.group(1)
upload = upload.group(1)
jitter = jitter.group(1)

speed_data = [
    {
        "measurement" : "internet_speed",
        "tags" : {
            "host": "RaspberryPiMyLifeUp"
        },
        "fields" : {
            "download": float(download),
            "upload": float(upload),
            "ping": float(ping),
            "jitter": float(jitter)
        }
    }
]
client = InfluxDBClient('localhost', 8086, 'admin', 'influxdb', 'internetspeed')

client.write_points(speed_data)
EOL

# Überprüfen, ob influxdb bereits installiert ist
if ! command -v influx &> /dev/null; then
    # InfluxDB installieren
    curl https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor | run_command "tee /usr/share/keyrings/influxdb-archive-keyring.gpg >/dev/null" "$sudo_available"

    echo "deb [signed-by=/usr/share/keyrings/influxdb-archive-keyring.gpg] https://repos.influxdata.com/debian $(lsb_release -cs) stable" | run_command "tee /etc/apt/sources.list.d/influxdb.list" "$sudo_available"

    run_command "apt update" "$sudo_available"
    run_command "apt install influxdb2 -y" "$sudo_available"

    run_command "systemctl unmask influxdb.service" "$sudo_available"
    run_command "systemctl start influxdb.service" "$sudo_available"
    run_command "systemctl enable influxdb.service" "$sudo_available"

    # Setze die InfluxDB-Zugangsdaten
    INFLUXDB_HOST="localhost"
    INFLUXDB_PORT="8086"
    INFLUXDB_USERNAME="admin"
    INFLUXDB_PASSWORD="influxdb"

    influx -host "$INFLUXDB_HOST" -port "$INFLUXDB_PORT" -token "$INFLUXDB_USERNAME:$INFLUXDB_PASSWORD" -organization "influxdb" -execute "CREATE USER $INFLUXDB_USERNAME WITH PASSWORD '$INFLUXDB_PASSWORD' WITH ALL PRIVILEGES"
fi

# Definiere die Befehle
COMMANDS=("CREATE DATABASE internetspeed" "CREATE USER \"speedmonitor\" WITH PASSWORD 'speed'" "GRANT ALL ON \"internetspeed\" to \"speedmonitor\"" "quit")

# Verbinde dich mit InfluxDB und führe die Befehle aus
for COMMAND in "${COMMANDS[@]}"; do
    echo "$COMMAND" | influx -host "$INFLUXDB_HOST" -port "$INFLUXDB_PORT" -token "$INFLUXDB_USERNAME:$INFLUXDB_PASSWORD" -organization "influxdb"
done

run_command "apt install python3-pip python3-influxdb -y" "$sudo_available"

# Cron-Job hinzufügen
echo '*/30 * * * * '$USER' python3 /home/'$USER'/speedtest.py' | run_command "tee -a /etc/crontab" "$sudo_available"
