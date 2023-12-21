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

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

run_command "apt install apache2 mariadb-server mariadb-client mariadb-common php php-gd php-mbstring php-mysqlnd php-curl php-xml php-cli php-soap php-intl php-xmlrpc php-zip php-common php-opcache php-gmp php-imagick php-pgsql -y" "$sudo_available"

run_command "systemctl start {apache2,mariadb}" "$sudo_available"
run_command "systemctl enable {apache2,mariadb}" "$sudo_available"

run_command "mysql_secure_installation" "$sudo_available"

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

curl https://packages.icinga.com/icinga.key | apt-key add -

sources_list="/etc/apt/sources.list.d/icinga-focal.list"
content="
deb http://packages.icinga.com/ubuntu icinga-focal main
deb-src http://packages.icinga.com/ubuntu icinga-focal main
"

# Erstelle die Datei und füge den Inhalt ein
echo "$content" | run_command "tee \"$sources_list\" > /dev/null

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
mysql_password="your_mysql_root_password"

# MySQL-Befehle
mysql_commands="
CREATE DATABASE icinga_ido_db;
GRANT ALL ON icinga_ido_db.* TO 'icinga_ido_user'@'localhost' IDENTIFIED BY 'Password321';
FLUSH PRIVILEGES;
EXIT;
"

# Ausführung der MySQL-Befehle
echo "$mysql_commands" | run_command "mysql -u \"$mysql_user\" -p \"$mysql_password\"" "$sudo_available"

run_command "mysql -u root -p icinga_ido_db < /usr/share/icinga2-ido-mysql/schema/mysql.sql" "$sudo_available"

# Anpassungen in der ido-mysql.conf-Datei
ido_mysql_conf="/etc/icinga2/features-available/ido-mysql.conf"
run_command "sed -i \"s/^library.*$/library \\"db_ido_mysql\\"/\" \"$ido_mysql_conf\"" "$sudo_available"
run_command "sed -i \"s/^object.*IDOConnection.*$/object IdoMysqlConnection \\"ido-mysql\\" \{/\" \"$ido_mysql_conf\"" "$sudo_available"
run_command "sed -i \"s/^.*user.*=.*$/  user = \\"icinga_ido_user\\",/\" \"$ido_mysql_conf\"" "$sudo_available"
run_command "sed -i \"s/^.*password.*=.*$/  password = \\"Password321\\",/\" \"$ido_mysql_conf\"" "$sudo_available"
run_command "sed -i \"s/^.*host.*=.*$/  host = \\"localhost\\",/\" \"$ido_mysql_conf\"" "$sudo_available"
run_command "sed -i \"s/^.*database.*=.*$/  database = \\"icinga_ido_db\\",/" \"$ido_mysql_conf\"" "$sudo_available"
run_command "sed -i \"s/^.*}/\}/\" \"$ido_mysql_conf\"" "$sudo_available"

run_command "icinga2 feature enable ido-mysql" "$sudo_available"

run_command "systemctl restart icinga2" "$sudo_available"

run_command "apt install icingaweb2 icingacli -y" "$sudo_available"


# MySQL-Befehle
mysql_commands="
CREATE DATABASE icingaweb2;
GRANT ALL ON icingaweb2.* TO 'icingaweb2user'@'localhost' IDENTIFIED BY 'P@ssword';
FLUSH PRIVILEGES;
EXIT;
"

# Ausführung der MySQL-Befehle
echo "$mysql_commands" | run_command "mysql -u \"$mysql_user\" -p \"$mysql_password\"" "$sudo_available"

# Erstelle das Token
icingacli_output=$(run_command"icingacli setup token create" "$sudo_available")

# Extrahiere das Token
icingacli_token=$(echo "$icingacli_output" | grep -oP 'The newly generated setup token is: \K.*')

run_command "apt upgrade -y" "$sudo_available"