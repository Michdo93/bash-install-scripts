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

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

# Den aktuellen Hostnamen abrufen
host_name=$(hostname)

# Abhängigkeiten installieren
run_command "apt install -y apache2 mariadb-server libapache2-mod-php php7.4-gd php7.4-json php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl php7.4-mcrypt php-imagick php7.4-xml php7.4-zip unzip -y" "$sudo_available"

./install_mariadb.bash

# OwnCloud herunterladen und extrahieren
wget https://download.owncloud.org/community/owncloud-complete-20210510.zip
unzip owncloud-complete-20210510.zip
run_command "mv owncloud /var/www/html/" "$sudo_available"
run_command "chown -R www-data:www-data /var/www/html/owncloud/" "$sudo_available"
run_command "chmod -R 755 /var/www/html/owncloud/" "$sudo_available"

# Apache VirtualHost-Konfiguration erstellen
cat <<EOL | run_command "tee /etc/apache2/sites-available/owncloud.conf" "$sudo_available"
<VirtualHost *:80>
    ServerAdmin webmaster@$host_name
    DocumentRoot /var/www/html/owncloud
    ServerName $host_name

    <Directory /var/www/html/owncloud/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
        SetEnv HOME /var/www/html/owncloud
        SetEnv HTTP_HOME /var/www/html/owncloud
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOL

# Apache-Konfigurationen aktivieren
run_command "a2ensite owncloud.conf" "$sudo_available"
run_command "a2enmod rewrite" "$sudo_available"
run_command "systemctl restart apache2" "$sudo_available"

# OwnCloud abschließen
run_command "-u www-data php /var/www/html/owncloud/occ maintenance:install --database \"mysql\" --database-name \"owncloud\"  --database-user \"root\" --database-pass \"password\" --admin-user \"admin\" --admin-pass \"adminpassword\"" "$sudo_available"

# Systemd-Dienst für OwnCloud erstellen
cat <<EOL | run_command "tee /etc/systemd/system/owncloud.service" "$sudo_available"
[Unit]
Description=OwnCloud
After=network.target

[Service]
ExecStart=/usr/bin/php -S 0.0.0.0:8080 -t /var/www/html/owncloud
Restart=on-failure
User=www-data
Group=www-data

[Install]
WantedBy=multi-user.target
EOL

# Systemd-Dienst aktivieren und starten
run_command "systemctl enable owncloud.service" "$sudo_available"
run_command "systemctl start owncloud.service" "$sudo_available"
