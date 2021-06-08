#!/bin/bash
yum -y update
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

yum -y install groupinstall "Developer-Tools"
yum -y install httpd httpd-devel
yum -y install wget unzip nano

yum -y install epel-release
yum -y install http://rpm.remirepo.net/enteeprise/remi-release-7.rpm
yum -y insyall yum-utils
yum-config-manager --disable remi-php54
yum-config-manager --enable remi-php72
yum -y insyall php php-{cli,curl,mysqlnd,devel,gd,pear,mcrypt,mbstring,xml,pear}

sudo tee /etc/yum.repo.d/MariaDB.repo<<EOOF
[mariadb]
name = mariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck = 1
EOF
echo

yum -y install MariaDB-server
systemctl start mariadb
systemctl enable --now mariad

mysql _secure_installation

mysql -u root -p -e "create database db_name; GRANT ALL PRIVILEGES ON db_name.* TO new_db_user@localhost IDENTIFIED BY 'db_user_pass'; FLUSH PRIVILEGES"

yum -y install freeradius freeradius-utils freeradius-mysql
systemctl enable --now radiusd.service

firewall-cmd –zone=public –add-port=1812/udp
firewall-cmd –zone=public –add-port=1813/udp
firewall-cmd –zone=public –permanent –add-port=1812/udp
firewall-cmd –zone=public –permanent –add-port=1813/udp
firewall-cmd --add-service={http,https,radius} --permanent
firewall-cmd --reload

mysql -u root -p radius < /etc/raddb/mods-config/sql/main/mysql/schema.sql
ln -s /etc/raddb/mods-available/sql /etc/raddb/mods-enabled/

nano /etc/raddb/mods-available/sql
chgrp -h radiusd /etc/raddb/mods-enabled/sql

wget https://github.com/lirantal/daloradius/archive/master.zip
unzip master.zip
mv daloradius-master/ daloradius
cd daloradius

mysql -u root -p radius < /root/Daloradius-Radiusv3/db/fr3-mysql-daloradius-and-freeradius.sql
mysql -u root -p radius < contrib/db/mysql-daloradius.sql
cd -
mv daloradius /var/www/html/

chown -R apache:apache /var/www/html/daloradius/
chmod 664 /var/www/html/daloradius/library/daloradius.conf.php

nano /var/www/html/daloradius/library/daloradius.conf.php

systemctl restart radiusd.service
systemctl restart httpd
systemctl restart mariadb
