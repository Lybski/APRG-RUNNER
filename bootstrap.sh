#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}
Update

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes python-software-properties vim htop curl git npm

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:chris-lea/redis-server
Update

echo "-- Install NodeJS --"
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -

#echo "-- Install Meteor --"
#curl https://install.meteor.com/ | sh

echo "-- Install packages --"
sudo apt-get install -y --force-yes apache2 mysql-server-5.6 git-core nodejs rabbitmq-server redis-server
sudo apt-get install -y --force-yes php7.0-common php7.0-dev php7.0-json php7.0-opcache php7.0-cli libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-mcrypt php7.0-mbstring php7.0-bcmath php7.0-zip php7.0-xml
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo a2enmod rewrite

echo "-- Creating virtual hosts --"
sudo ln -fs /vagrant/app /var/www/app
cat << EOF | sudo tee /etc/apache2/sites-available/000-default.conf
<Directory "/var/www/">
    AllowOverride All
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/app
    ServerName app.dev
    <Directory "/var/www/app">
             RewriteEngine On
             RewriteBase /
             RewriteCond %{REQUEST_FILENAME} !-f
             RewriteCond %{REQUEST_FILENAME} !-d
             RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/phpmyadmin
    ServerName phpmyadmin.dev
</VirtualHost>
EOF

echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo "-- Install phpMyAdmin --"
wget -k https://files.phpmyadmin.net/phpMyAdmin/4.0.10.11/phpMyAdmin-4.0.10.11-english.tar.gz
sudo tar -xzvf phpMyAdmin-4.0.10.11-english.tar.gz -C /var/www/
sudo rm phpMyAdmin-4.0.10.11-english.tar.gz
sudo mv /var/www/phpMyAdmin-4.0.10.11-english/ /var/www/phpmyadmin

echo "-- Setup databases --"
cat << EOF | sudo tee /etc/mysql/conf.d/utf-8.cnf
[mysqld]
collation_server = utf8_general_ci
character_set_server = utf8
EOF
sudo sed -i 's/bind-add/#bind-add/g' /etc/mysql/my.cnf

mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -proot -e "DROP DATABASE IF EXISTS runner";
mysql -uroot -proot -e "CREATE DATABASE runner";
mysql -uroot -proot kis < /vagrant/runner.sql;

sudo service mysql restart

echo "...done!";
echo "Webserver: http://192.168.100.100";
echo "Database: Host 192.168.100.100";
echo "Database: Port 3306";
echo "Database: User/Pass root/root";
