#!/bin/bash

set -e  # exit on the first command failure

apt-get install -y install apache2 php wget unzip libapache2-mod-php php-{gd,common,mail,mail-mime,mysql,pear,db,mbstring,xml,curl}

apt install -y software-properties-common
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mariadb.mirror.liquidtelecom.com/repo/10.5/ubuntu bionic main'
apt update
apt install mariadb-server mariadb-client

mysql_secure_installation

mysql -u root -p
CREATE DATABASE radius;
GRANT ALL ON radius.* TO radius@localhost IDENTIFIED BY "Str0ngR@diusPass";
FLUSH PRIVILEGES;
QUIT

apt -y install freeradius freeradius-mysql freeradius-utils
mysql -u root -p radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sq
ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/

nano /etc/freeradius/3.0/mods-enabled/sql

chgrp -h freerad /etc/freeradius/3.0/mods-available/sql
chown -R freerad:freerad /etc/freeradius/3.0/mods-enabled/sql

systemctl restart freeradius.service

wget https://github.com/lirantal/daloradius/archive/master.zip
unzip master.zip
mv daloradius-master daloradius
cd daloradius
sudo mysql -u root -p radius < /root/Daloradius-Radiusv3/db/fr3-mysql-daloradius-and-freeradius.sql
sudo mysql -u root -p radius < contrib/db/mysql-daloradius.sql
cd -
mv daloradius /var/www/html/

sudo chown -R www-data:www-data /var/www/html/daloradius/
sudo chmod 664 /var/www/html/daloradius/library/daloradius.conf.php

nano /var/www/html/daloradius/library/daloradius.conf.php
systemctl restart freeradius.service apache2

cd -
