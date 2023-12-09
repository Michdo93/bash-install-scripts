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

sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install apache2 mariadb-server mariadb-client mariadb-common php php-gd php-mbstring php-mysqlnd php-curl php-xml php-cli php-soap php-intl php-xmlrpc php-zip php-common php-opcache php-gmp php-imagick php-pgsql -y

sudo systemctl start {apache2,mariadb}
sudo systemctl enable {apache2,mariadb}

sudo mysql_secure_installation

# Überprüfe die Ubuntu-Version und wende die Änderungen an
if [[ $ubuntu_version == "22.04" ]]; then
    apply_changes "/etc/php/8.1/apache2/php.ini"
elif [[ $ubuntu_version == "20.04" ]]; then
    apply_changes "/etc/php/7.4/apache2/php.ini"
else
    echo "Nicht unterstützte Ubuntu-Version."
fi

sudo systemctl restart apache2
sudo systemctl enable apache2

curl https://packages.icinga.com/icinga.key | apt-key add -

sources_list="/etc/apt/sources.list.d/icinga-focal.list"
content="
deb http://packages.icinga.com/ubuntu icinga-focal main
deb-src http://packages.icinga.com/ubuntu icinga-focal main
"

# Erstelle die Datei und füge den Inhalt ein
echo "$content" | sudo tee "$sources_list" > /dev/null

sudo apt update
sudo apt install icinga2 monitoring-plugins

sudo systemctl start icinga2
sudo systemctl enable icinga2

# Setze DEBIAN_FRONTEND auf noninteractive, um interaktive Fragen zu verhindern
export DEBIAN_FRONTEND=noninteractive

# Installiere icinga2-ido-mysql ohne interaktive Fragen
sudo apt-get install -y icinga2-ido-mysql

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
echo "$mysql_commands" | sudo mysql -u"$mysql_user" -p"$mysql_password"

sudo mysql -u root -p icinga_ido_db < /usr/share/icinga2-ido-mysql/schema/mysql.sql

# Anpassungen in der ido-mysql.conf-Datei
ido_mysql_conf="/etc/icinga2/features-available/ido-mysql.conf"
sudo sed -i "s/^library.*$/library \"db_ido_mysql\"/" "$ido_mysql_conf"
sudo sed -i "s/^object.*IDOConnection.*$/object IdoMysqlConnection \"ido-mysql\" \{/" "$ido_mysql_conf"
sudo sed -i "s/^.*user.*=.*$/  user = \"icinga_ido_user\",/" "$ido_mysql_conf"
sudo sed -i "s/^.*password.*=.*$/  password = \"Password321\",/" "$ido_mysql_conf"
sudo sed -i "s/^.*host.*=.*$/  host = \"localhost\",/" "$ido_mysql_conf"
sudo sed -i "s/^.*database.*=.*$/  database = \"icinga_ido_db\",/" "$ido_mysql_conf"
sudo sed -i "s/^.*}/\}/" "$ido_mysql_conf"

sudo icinga2 feature enable ido-mysql

sudo systemctl restart icinga2 

sudo apt install icingaweb2 icingacli -y


# MySQL-Befehle
mysql_commands="
CREATE DATABASE icingaweb2;
GRANT ALL ON icingaweb2.* TO 'icingaweb2user'@'localhost' IDENTIFIED BY 'P@ssword';
FLUSH PRIVILEGES;
EXIT;
"

# Ausführung der MySQL-Befehle
echo "$mysql_commands" | sudo mysql -u"$mysql_user" -p"$mysql_password"

# Erstelle das Token
icingacli_output=$(sudo icingacli setup token create)

# Extrahiere das Token
icingacli_token=$(echo "$icingacli_output" | grep -oP 'The newly generated setup token is: \K.*')

sudo apt upgrade -y
