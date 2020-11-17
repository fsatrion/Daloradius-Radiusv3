# APACHE install
yum -y update
yum -y install groupinstall "Developer-Tools"
yum -y install httpd httpd-devel

#MariaDB Install
sudo tee /etc/yum.repo.d/MariaDB.repo<<EOOF
[mariadb]
name = mariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck = 1
EOF
systemctl enable mariadb
systemctl start mariadb

#SQL Config
mysql _secure_installation

#Databse Config
mysql -u root -p
CREATE DATABASE radius;
GRANT ALL ON radius.* TO radius@localhost IDENTIFED BY "123";
FLUSH PRIVILEGES;
\q

#PHP Install
yum -y install epel-release
yum -y install http://rpm.remirepo.net/enteeprise/remi-release-7.rpm
yum -y insyall yum-utils
yum-config-manager --disable remi-php54
yum-config-manager --enable remi-php72
yum -y insyall php php-{cli,curl,mysqlnd,devel,gd,pear,mcrypt,mbstring,xml,pear}
php -v

#PHPMyAdmin install
yum -y install phpmyadmin

#wget install
yum -y install wget

#nano install
yum -y install nano
