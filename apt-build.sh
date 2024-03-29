#!/bin/bash
apt -y install apache2 unzip wget
apt -y install php libapache2-mod-php php-{gd,common,mail,mail-mime,mysql,pear,db,mbstring,xml,curl}

apt install -y software-properties-common
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mariadb.mirror.liquidtelecom.com/repo/10.5/ubuntu bionic main'
apt update
apt install -y mariadb-server

sudo mysql_secure_installation
echo
echo -e "Enter your sql password"
mysql -u root -p -e "create database db_name; GRANT ALL PRIVILEGES ON db_name.* TO new_db_user@localhost IDENTIFIED BY 'db_user_pass'; FLUSH PRIVILEGES"

apt -y install freeradius freeradius-mysql freeradius-utils
echo
echo -e "Enter your sql password"
mysql -u root -p radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql
ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/

nano /etc/freeradius/3.0/mods-enabled/sql

chgrp -h freerad /etc/freeradius/3.0/mods-available/sql
chown -R freerad:freerad /etc/freeradius/3.0/mods-enabled/sql

systemctl restart freeradius.service

wget https://github.com/lirantal/daloradius/archive/master.zip
unzip master.zip
mv daloradius-master daloradius
cd daloradius
echo
echo -e "Enter your sql password"
mysql -u root -p radius < /root/Daloradius-Radiusv3/db/fr3-mysql-daloradius-and-freeradius.sql
echo
echo -e "Enter your sql password"
mysql -u root -p radius < contrib/db/mysql-daloradius.sql
cd -
mv daloradius /var/www/html/

cp /var/www/html/daloradius/library/daloradius.conf.php.sample /var/www/html/daloradius/library/daloradius.conf.php
nano /var/www/html/daloradius/library/daloradius.conf.php

chown -R www-data:www-data /var/www/html/daloradius/
chmod 664 /var/www/html/daloradius/library/daloradius.conf.php

systemctl restart freeradius.service 
systemctl restart apache2 
systemctl restart mariadb
