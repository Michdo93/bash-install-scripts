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
run_command "apt install curl git wget net-tools -y" "$sudo_available"
run_command "apt install expect -y" "sudo_available"

wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

run_command "apt update" "$sudo_available"
run_command "apt install influxdb2 -y" "$sudo_available"

run_command "systemctl start influxdb.service" "$sudo_available"
run_command "systemctl enable influxdb.service" "$sudo_available"

expect_script=$(cat << 'EOF'
spawn influx setup
expect "Please type your primary username" { send "influxdb\n" }
expect "Please type your password" { send "influxdb\n" }
expect "Please type your password again" { send "influxdb\n" }
expect "Please type your primary organization name" { send "influxdb\n" }
expect "Please type your primary bucket name" { send "influxdb\n" }
expect "Please type your retention period in hours, or 0 for infinite" { send "0\n" }
expect "Setup with these parameters?" { send "\n" }
expect eof
EOF
)

# Führe das Expect-Skript aus
echo "$expect_script" | expect -

