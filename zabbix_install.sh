#!/bin/bash
apt install screen figlet toilet cowsay -y > /dev/null
rm /tmp/finish
figlet -c "Script"
figlet -c "de"
figlet -c "Instalacao"
figlet -c "ZABBIX"
echo "Mv2 SOLUTIONS SUPORTE E CONSULTORIA EM TI http://mv2.solutions (24)99841-1506"
echo
echo
echo "ADICIONANDO REPOSITORIOS"
sleep 3
echo 'deb http://deb.debian.org/debian/ buster main contrib non-free' >  /etc/apt/sources.list.d/nonfree.list
echo 'deb http://deb.debian.org/debian/ buster-updates main contrib non-free' >>  /etc/apt/sources.list.d/nonfree.list
echo 'deb http://security.debian.org/debian-security buster/updates main contrib non-free' >>  /etc/apt/sources.list.d/nonfree.list
apt update
echo
echo
echo "INICIANDO O PROCESSO DE INSTALAÇÃO DO ZABBIX"
echo
sleep 3
echo
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bdebian11_all.deb
dpkg -i zabbix-release_6.0-4+debian11_all.deb
apt update
apt install locales -y
locale-gen pt_BR.UTF-8
update-locale LANG=pt_BR.UTF-8
apt install zabbix-server-mysql zabbix-frontend-php \
zabbix-apache-conf zabbix-sql-scripts zabbix-agent zabbix-get \
zabbix-sender apache2 php php-cgi libapache2-mod-php \
php-common php-pear php-mbstring php-mysql php-gd php-xml-util php-bcmath \
php-net-socket nmap snmp snmp-mibs-downloader mariadb-server htop mtr curl -y
sed -i 's/mibs :/# mibs :/g' /etc/snmp/snmp.conf
echo
echo "INICIANDO A CONFIGURAÇÃO DO MYSQL"
sleep 3
echo
echo
mysql -uroot -e "create database zabbix character set utf8mb4 collate utf8mb4_bin";
mysql -uroot -e "create user zabbix@localhost identified by 'cisco'";
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost";
echo
echo "CRIANDO O BANCO DE DADOS"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -pcisco zabbix
echo
echo "CONFIGURANDO O PHP"
sleep 3
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/g' /etc/apache2/conf-enabled/zabbix.conf
sed -i 's/# DBPassword=/DBPassword=cisco/g' /etc/zabbix/zabbix_server.conf
echo
wget -c -P /usr/lib/zabbix/alertscripts https://raw.githubusercontent.com/mv2suporte/script/main/wppsendgrupo.sh /usr/lib/zabbix/alertscripts
wget -c -P /usr/lib/zabbix/alertscripts https://raw.githubusercontent.com/mv2suporte/script/main/wppsend.sh /usr/lib/zabbix/alertscripts
chmod a+x /usr/lib/zabbix/alertscripts/wppsendgrupo.sh
chmod a+x /usr/lib/zabbix/alertscripts/wppsend.sh
echo
echo "INSTALANDO O GRAFANA"
sleep 3
echo
apt install adduser libfontconfig -y
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_9.2.2_amd64.deb
dpkg -i grafana-enterprise_9.2.2_amd64.deb
grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins update alexanderzobnin-zabbix-app
echo
echo
echo "ADICIONANDO ARQUIVOS NA INICIALIZAÇÃO"
sleep 3
echo
service grafana-server restart
service zabbix-server restart
service zabbix-agent restart
service apache2 restart
echo
systemctl enable zabbix-server.service
systemctl enable zabbix-agent.service
systemctl enable grafana-server.service
echo
figlet -c "FIM"
sleep 3
echo
echo "Mv2 SOLUTIONS"
