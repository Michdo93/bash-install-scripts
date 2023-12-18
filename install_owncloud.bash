#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

# Den aktuellen Hostnamen abrufen
host_name=$(hostname)

# Abhängigkeiten installieren
sudo apt install -y apache2 mariadb-server libapache2-mod-php php7.4-gd php7.4-json php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl php7.4-mcrypt php-imagick php7.4-xml php7.4-zip unzip -y

./install_mariadb.bash

# OwnCloud herunterladen und extrahieren
wget https://download.owncloud.org/community/owncloud-complete-20210510.zip
unzip owncloud-complete-20210510.zip
sudo mv owncloud /var/www/html/
sudo chown -R www-data:www-data /var/www/html/owncloud/
sudo chmod -R 755 /var/www/html/owncloud/

# Apache VirtualHost-Konfiguration erstellen
cat <<EOL | sudo tee /etc/apache2/sites-available/owncloud.conf
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
sudo a2ensite owncloud.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# OwnCloud abschließen
sudo -u www-data php /var/www/html/owncloud/occ maintenance:install --database "mysql" --database-name "owncloud"  --database-user "root" --database-pass "password" --admin-user "admin" --admin-pass "adminpassword"

# Optional: Redis als Cache für OwnCloud aktivieren (erfordert Redis-Server-Installation)
# sudo apt install -y redis-server
# sudo -u www-data php /var/www/html/owncloud/occ config:system:set memcache.local --value '\OC\Memcache\Redis'
# sudo -u www-data php /var/www/html/owncloud/occ config:system:set redis --value '{"host": "localhost", "port": "6379"}'

# Systemd-Dienst für OwnCloud erstellen
cat <<EOL | sudo tee /etc/systemd/system/owncloud.service
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
sudo systemctl enable owncloud.service
sudo systemctl start owncloud.service
