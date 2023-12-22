# bash-install-scripts
A few bash installation scripts for Ubuntu, Raspbian and Debian.

## Configurations

Because several scripts run automatically and the applications are installed, they are initialized with standard configurations and passwords. These scripts help to customize these configurations.

### Changing Icinga IDO (Icinga Data Output) admin password

The default username and password for Icinga IDO are `icinga_ido` and `icinga_ido`. You can change it with: 

```
./icinga2-change-icinga_ido-pwd.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/icinga2-change-icinga_ido-pwd.bash -O - | bash
```

### Changing Icinga Web 2 admin password

The default username and password for Icinga Web 2 are `icingaweb2user` and `icingaweb2user`. You can change it with: 

```
./icinga2-change-icingaweb2user-pwd.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/icinga2-change-icingaweb2user-pwd.bash -O - | bash
```

### Changing InfluxDB 2 admin password

The default username and password for InfluxDB 2 are `admin` and `influxdb`. You can change it with: 

```
./influxdb2-change-admin-pwd.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/influxdb2-change-admin-pwd.bash -O - | bash
```

### Changing MariaDB root password

The default username and password for MariaDB are `mariadb_root` and `mariadb_root`. You can change it with: 

```
./mariadb-change-root-pwd.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/mariadb-change-root-pwd.bash -O - | bash
```

### Creating new MariaDB user

```
./mariadb-create-new-user.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/mariadb-create-new-user.bash -O - | bash
```

### Changing MySQL root password

The default username and password for MySQL are `mysql_root` and `mysql_root`. You can change it with: 

```
./mysql-change-root-pwd.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/mysql-change-root-pwd.bash -O - | bash
```

### Creating new MySQL user

```
./mysql-create-new-user.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/mysql-create-new-user.bash -O - | bash
```

### Changing Nextcloud admin password

The default username and password for Nextcloud are `nextcloud` and `nextcloud`. You can change it with: 

```
./nextcloud-change-nextcloud-pwd.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/nextcloud-change-nextcloud-pwd.bash -O - | bash
```
### Changing ownCloud admin password

The default username and password for ownCloud are `owncloud` and `owncloud`. You can change it with: 

```
./owncloud-change-owncloud-pwd.bash
```

or

```
wget https://raw.githubusercontent.com/Michdo93/bash-install-scripts/main/config/owncloud-change-owncloud-pwd.bash -O - | bash
```
