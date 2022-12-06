#!/bin/bash
apt install screen figlet toilet cowsay -y > /dev/null
rm /tmp/finish
figlet -c "Script"
figlet -c "de"
figlet -c "Instalacao"
figlet -c "PHPIPAM"
echo "Mv2 SOLUTIONS SUPORTE E CONSULTORIA EM TI http://mv2.solutions (24)99841-1506"
sleep 5
echo "INSTALANDO AS DEPENDENCIAS"
sleep 2
apt install apache2 php libapache2-mod-php php-curl php-gmp php-mbstring php-gd php-dom php-pear mariadb-server git -y
echo "PREPARANDO O BANCO DE DADOS"
echo
sleep 2
mysql -uroot -e "create database phpipam";
mysql -uroot -e "GRANT ALL PRIVILEGES ON phpipam.* TO 'phpipam'@'localhost' IDENTIFIED BY 'phpipamadmin'";
echo
echo "BAIXANDO O PHPIPAM"
sleep 2
echo
rm /var/www/html/index.html
git clone https://github.com/phpipam/phpipam.git /var/www/html/phpipam
cp /var/www/html/phpipam/config.dist.php /var/www/html/phpipam/config.php
a2enmod rewrite
sleep 4
service apache2 restart
figlet -c "FIM"