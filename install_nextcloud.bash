#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt update && sudo apt upgrade -y
sudo apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql \
php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip -y

./install_mysql.bash

# Nextcloud herunterladen und extrahieren
wget https://download.nextcloud.com/server/releases/latest.tar.bz2
tar -xvjf latest.tar.bz2
sudo mv nextcloud /var/www/html/
sudo chown -R www-data:www-data /var/www/html/nextcloud/
sudo chmod -R 755 /var/www/html/nextcloud/

# Apache-Konfiguration für Nextcloud erstellen
# Den aktuellen Hostnamen abrufen
host_name=$(hostname)

# Apache VirtualHost-Konfiguration erstellen
cat <<EOL | sudo tee /etc/apache2/sites-available/nextcloud.conf
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

sudo a2ensite nextcloud.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Nextcloud abschließen
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:install --database "mysql" --database-name "nextcloud"  --database-user "root" --database-pass "password" --admin-user "admin" --admin-pass "adminpassword"

# Abschließende Nachricht
echo "Nextcloud wurde erfolgreich installiert. Öffnen Sie http://your_domain_or_ip in Ihrem Browser."

sudo cp -r nextcloud /var/www

sudo chown -R www-data:www-data /var/www/nextcloud
