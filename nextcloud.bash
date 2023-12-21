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

run_command "apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip -y" "$sudo_available"

./install_mysql.bash

# Nextcloud herunterladen und extrahieren
wget https://download.nextcloud.com/server/releases/latest.tar.bz2
tar -xvjf latest.tar.bz2
run_command "mv nextcloud /var/www/html/" "$sudo_available"
run_command "chown -R www-data:www-data /var/www/html/nextcloud/" "$sudo_available"
run_command "chmod -R 755 /var/www/html/nextcloud/" "$sudo_available"

# Apache-Konfiguration für Nextcloud erstellen
# Den aktuellen Hostnamen abrufen
host_name=$(hostname)

# Apache VirtualHost-Konfiguration erstellen
cat <<EOL | run_command "tee /etc/apache2/sites-available/nextcloud.conf" "$sudo_available"
<VirtualHost *:80>
    ServerAdmin webmaster@$host_name
    DocumentRoot /var/www/html/nextcloud
    ServerName $host_name

    <Directory /var/www/html/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
        SetEnv HOME /var/www/html/nextcloud
        SetEnv HTTP_HOME /var/www/html/nextcloud
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOL

run_command "a2ensite nextcloud.conf" "$sudo_available"
run_command "a2enmod rewrite" "$sudo_available"
run_command "systemctl restart apache2" "$sudo_available"

# Nextcloud abschließen
run_command "-u www-data php /var/www/html/nextcloud/occ maintenance:install --database \"mysql\" --database-name \"nextcloud\" --database-user \"root\" --database-pass \"password\" --admin-user \"admin\" --admin-pass \"adminpassword\"" "$sudo_available"

# Systemd-Dienst für Nextcloud erstellen
cat <<EOL | run_command "tee /etc/systemd/system/nextcloud.service" "$sudo_available"
[Unit]
Description=Nextcloud
After=network.target mariadb.service

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/usr/bin/php -S 0.0.0.0:8080 -t /var/www/html/nextcloud
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Systemd-Dienst aktivieren und starten
run_command "systemctl enable nextcloud.service" "$sudo_available"
run_command "systemctl start nextcloud.service" "$sudo_available"