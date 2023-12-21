#!/bin/bash

# Überprüfe die Ubuntu-Version
ubuntu_version=$(lsb_release -rs)

# Definiere die gewünschten Änderungen
changes="
memory_limit = 256M
post_max_size = 64M
upload_max_filesize = 100M
max_execution_time = 300
default_charset = \"UTF-8\"
date.timezone = \"Europe/Berlin\"
cgi.fix_pathinfo=0
"

# Funktion zum Anwenden der Änderungen
apply_changes() {
    echo "$changes" | sudo tee -a "$1" > /dev/null
    echo "Änderungen in $1 angewendet."
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

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von weiteren Paketen
run_command "apt install curl git wget net-tools apache2 php php-gd php-mbstring php-mysqlnd php-curl php-xml php-cli php-soap php-intl php-xmlrpc php-zip php-common php-opcache php-gmp php-imagick php-pgsql -y" "$sudo_available"

run_command "systemctl start apache2" "$sudo_available"
run_command "systemctl enable apache2" "$sudo_available"

# Überprüfen, ob MariaDB bereits installiert ist
if ! command -v mariadb &> /dev/null; then
    # Installieren von Paketen
    run_command "apt install mariadb-server mariadb-client mariadb-common -y" "$sudo_available"

    # Durchführen der MariaDB-Sicherheitsinstallation
    echo -e "mariadb_root\nmariadb_root\nY\nn\nY\nY\nY\n" | run_command "mysql_secure_installation" "$sudo_available"

    run_command "systemctl start mariadb.service" "$sudo_available"
    run_command "systemctl enable mariadb.service" "$sudo_available"
fi

# Überprüfe die Ubuntu-Version und wende die Änderungen an
if [[ $ubuntu_version == "22.04" ]]; then
    apply_changes "/etc/php/8.1/apache2/php.ini"
elif [[ $ubuntu_version == "20.04" ]]; then
    apply_changes "/etc/php/7.4/apache2/php.ini"
else
    echo "Nicht unterstützte Ubuntu-Version."
fi

run_command "systemctl restart apache2" "$sudo_available"
run_command "systemctl enable apache2" "$sudo_available"

curl https://packages.icinga.com/icinga.key | run_command "apt-key add -" "$sudo_available"

sources_list="/etc/apt/sources.list.d/icinga-focal.list"
content="
deb http://packages.icinga.com/ubuntu icinga-focal main
deb-src http://packages.icinga.com/ubuntu icinga-focal main
"

# Erstelle die Datei und füge den Inhalt ein
echo "$content" | run_command "tee \"$sources_list\" > /dev/null" "$sudo_available"

run_command "apt update" "$sudo_available"
run_command "apt install icinga2 monitoring-plugins -y" "$sudo_available"

run_command "systemctl start icinga2" "$sudo_available"
run_command "systemctl enable icinga2" "$sudo_available"

# Setze DEBIAN_FRONTEND auf noninteractive, um interaktive Fragen zu verhindern
export DEBIAN_FRONTEND=noninteractive

# Installiere icinga2-ido-mysql ohne interaktive Fragen
run_command "apt-get install icinga2-ido-mysql -y" "$sudo_available"

# Setze die Interaktivität zurück (optional, je nach Bedarf)
export DEBIAN_FRONTEND=dialog

# MySQL-Anmeldedaten
mysql_user="root"
mysql_password="mariadb_root"

# MySQL-Befehle
mysql_commands="
CREATE DATABASE icinga_ido_db;
GRANT ALL ON icinga_ido_db.* TO 'icinga_ido'@'localhost' IDENTIFIED BY 'icinga_ido';
FLUSH PRIVILEGES;
EXIT;
"

# Ausführung der MySQL-Befehle
echo "$mysql_commands" | run_command "mysql -u \"$mysql_user\" -p\"$mysql_password\"" "$sudo_available"

run_command "mysql -u root -p icinga_ido_db < /usr/share/icinga2-ido-mysql
