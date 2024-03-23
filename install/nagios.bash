#!/bin/bash

nagiosadmin="nagiosadmin"

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

run_command "apt install autoconf bc gawk dc build-essential gcc libc6 make wget unzip apache2 php libapache2-mod-php libgd-dev libmcrypt-dev make libssl-dev snmp libnet-snmp-perl gettext -y" "$sudo_available"

cd /home/$USER
wget https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz
tar -xf nagios-4.4.6.tar.gz
cd nagioscore-*/

run_command "./configure --with-httpd-conf=/etc/apache2/sites-enabled" "$sudo_available"
run_command "make all" "$sudo_available"

run_command "make install-groups-users" "$sudo_available"
run_command "usermod -a -G nagios www-data" "$sudo_available"

run_command "make install" "$sudo_available"
run_command "make install-daemoninit" "$sudo_available"
run_command "make install-commandmode" "$sudo_available"
run_command "make install-config" "$sudo_available"
run_command "make install-webconf" "$sudo_available"

run_command "a2enmod rewrite cgi" "$sudo_available"

run_command "systemctl restart apache2" "$sudo_available"

run_command "htpasswd -c -b /usr/local/nagios/etc/htpasswd.users $nagiosadmin $nagiosadmin" "$sudo_available"

run_command "apt install monitoring-plugins nagios-nrpe-plugin -y" "$sudo_available"

run_command "mkdir -p /usr/local/nagios/etc/servers" "$sudo_available"
run_command "mkdir -p /usr/local/nagios/etc/printers" "$sudo_available"
run_command "mkdir -p /usr/local/nagios/etc/switches" "$sudo_available"
run_command "mkdir -p /usr/local/nagios/etc/routers" "$sudo_available"

run_command "chown -R nagios:nagios /usr/local/nagios/etc" "$sudo_available"

run_command "sed -i s/^#cfg_dir/cfg_dir/g /usr/local/nagios/etc/nagios.cfg" "$sudo_available"

echo '$USER1$=/usr/lib/nagios/plugins' | run_command "tee -a /usr/local/nagios/etc/resource.cfg" "$sudo_available"

echo -e '\n\n' | run_command "tee -a /usr/local/nagios/etc/objects/commands.cfg" "$sudo_available"
echo 'define command{' | run_command "tee -a /usr/local/nagios/etc/objects/commands.cfg" "$sudo_available"
echo '    command_name check_nrpe' | run_command "tee -a /usr/local/nagios/etc/objects/commands.cfg" "$sudo_available"
echo '    command_line \$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -c \$ARG1\$' | run_command "tee -a /usr/local/nagios/etc/objects/commands.cfg" "$sudo_available"
echo '}' | run_command "tee -a /usr/local/nagios/etc/objects/commands.cfg" "$sudo_available"

run_command "systemctl start nagios" "$sudo_available"
run_command "systemctl enable nagios" "$sudo_available"

run_command "systemctl restart apache2" "$sudo_available"

echo 'PATH=$PATH:/usr/lib/nagios/plugins' >> ~/.bashrc
. ~/.bashrc
