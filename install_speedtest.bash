#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install apt-transport-https gnupg1 dirmngr lsb-release -y

curl -L https://packagecloud.io/ookla/speedtest-cli/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/speedtestcli-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/speedtestcli-archive-keyring.gpg] https://packagecloud.io/ookla/speedtest-cli/debian/ $(lsb_release -cs) main" | sudo tee  /etc/apt/sources.list.d/speedtest.list

sudo apt update

sudo apt install speedtest -y

touch /home/pi/speedtest.py
mkdir /home/pi/speedtest

cat <<EOL > "/home/pi/speedtest.py"
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
client = InfluxDBClient('localhost', 8086, 'speedmonitor', 'speed', 'internetspeed')

client.write_points(speed_data)
EOL

# install influxdb

sudo apt update
sudo apt upgrade -y

curl https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/influxdb-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/influxdb-archive-keyring.gpg] https://repos.influxdata.com/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo apt update

sudo apt install influxdb2 -y

sudo systemctl unmask influxdb.service
sudo systemctl start influxdb.service
sudo systemctl enable influxdb.service


#!/bin/bash

# Setze die InfluxDB-Zugangsdaten
INFLUXDB_HOST="localhost"
INFLUXDB_PORT="8086"
INFLUXDB_USERNAME="admin"
INFLUXDB_PASSWORD="influxdb"

influx -host "$INFLUXDB_HOST" -port "$INFLUXDB_PORT" -execute "CREATE USER $INFLUXDB_USERNAME WITH PASSWORD '$INFLUXDB_PASSWORD' WITH ALL PRIVILEGES"

# Definiere die Befehle
COMMANDS=("CREATE DATABASE internetspeed" "CREATE USER \"speedmonitor\" WITH PASSWORD 'speed'" "GRANT ALL ON \"internetspeed\" to \"speedmonitor\"" "quit")

# Verbinde dich mit InfluxDB und führe die Befehle aus
for COMMAND in "${COMMANDS[@]}"; do
    echo "$COMMAND" | influx -host "$INFLUXDB_HOST" -port "$INFLUXDB_PORT" -username "$INFLUXDB_USERNAME" -password "$INFLUXDB_PASSWORD"
done

sudo apt install python3-influxdb -y

echo '*/30 * * * * pi python3 /home/pi/speedtest.py' | sudo tee -a /etc/crontab
