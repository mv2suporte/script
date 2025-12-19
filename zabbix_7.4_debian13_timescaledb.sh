#!/bin/bash
set -e

### VARIÁVEIS ###
ZABBIX_DB="zabbix"
ZABBIX_USER="zabbix"
ZABBIX_PASS="zabbix@123"
TIMEZONE="America/Sao_Paulo"
PG_VERSION="17"

echo "==== Timezone ===="
timedatectl set-timezone $TIMEZONE

echo "==== Atualizando sistema ===="
apt update && apt upgrade -y
apt install -y curl wget gnupg2 lsb-release ca-certificates sudo vim

echo "==== PostgreSQL $PG_VERSION ===="
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | gpg --dearmor > /usr/share/keyrings/postgresql.gpg

echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] \
http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" \

apt update
apt install -y postgresql-$PG_VERSION postgresql-contrib

echo "==== Atualizando PostgreSQL $PG_VERSION ===="
echo "deb http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
apt update
apt install -y postgresql-$PG_VERSION

echo "==== TimescaleDB ===="
wget -qO- https://packagecloud.io/timescale/timescaledb/gpgkey \
  | gpg --dearmor > /usr/share/keyrings/timescaledb.gpg

echo "deb [signed-by=/usr/share/keyrings/timescaledb.gpg] \
https://packagecloud.io/timescale/timescaledb/debian/ trixie main" \
> /etc/apt/sources.list.d/timescaledb.list

apt update
apt install -y timescaledb-2-postgresql-$PG_VERSION
timescaledb-tune --yes

systemctl restart postgresql

echo "==== Criando banco Zabbix ===="
sudo -u postgres psql <<EOF
CREATE DATABASE $ZABBIX_DB;
CREATE USER $ZABBIX_USER WITH PASSWORD '$ZABBIX_PASS';
ALTER DATABASE $ZABBIX_DB OWNER TO $ZABBIX_USER;
\c $ZABBIX_DB
CREATE EXTENSION IF NOT EXISTS timescaledb;
EOF

echo "==== Zabbix 7.4 ===="
wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb
dpkg -i zabbix-release_latest_7.4+debian13_all.deb
apt update

echo "==== INSTALANDO SERVICOS ===="
apt install -y \
  zabbix-server-pgsql \
  zabbix-frontend-php \
  php8.4-pgsql \
  zabbix-apache-conf \
  zabbix-sql-scripts \
  zabbix-agent \
  zabbix-get \
  zabbix-sender \
  php \
  php-cgi \
  libapache2-mod-php \
  php-common \
  php-pear \
  php-mbstring \
  php-pgsql \
  php-gd \
  php-xml-util \
  php-bcmath \
  php-net-socket \
  nmap \
  snmpd \
  snmp \
  htop \
  mtr \
  curl \
  php-fpm
  
echo "==== Importando schema ===="
zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | \
PGPASSWORD=$ZABBIX_PASS psql -U $ZABBIX_USER -h localhost $ZABBIX_DB

echo "==== Configurando Zabbix Server ===="
sed -i "s/^# DBPassword=/DBPassword=$ZABBIX_PASS/" /etc/zabbix/zabbix_server.conf

cat <<EOF >> /etc/zabbix/zabbix_server.conf

### PERFORMANCE ###
CacheSize=4G
HistoryCacheSize=1G
TrendCacheSize=256M
ValueCacheSize=4G

StartPollers=80
StartPollersUnreachable=15
StartTrappers=10
StartPingers=10
StartDiscoverers=10
EOF

echo "==== PHP tuning ===="
sed -i "s/^max_execution_time.*/max_execution_time = 300/" /etc/php/*/apache2/php.ini
sed -i "s/^memory_limit.*/memory_limit = 512M/" /etc/php/*/apache2/php.ini
sed -i "s|^;date.timezone.*|date.timezone = $TIMEZONE|" /etc/php/*/apache2/php.ini

echo "==== Adicionando repositorio ===="
echo 'deb http://deb.debian.org/debian/ trixie non-free main contrib' >  /etc/apt/sources.list.d/nonfree.list
apt update
apt install -y snmp-mibs-downloader

echo "==== removendo repositorio ===="
rm /etc/apt/sources.list.d/nonfree.list

echo "==== Alterando snmp e pagina do zabbix ===="
sed -i 's/mibs :/# mibs :/g' /etc/snmp/snmp.conf
sed -i 's|DocumentRoot /var/www/html|DocumentRoot /usr/share/zabbix/ui|' /etc/apache2/sites-available/000-default.conf

echo "==== Serviços ===="
systemctl enable postgresql apache2 zabbix-server zabbix-agent
systemctl restart postgresql apache2 zabbix-server zabbix-agent

echo "==== INSTALANDO O GRAFANA ===="
sleep 3
sudo apt-get install -y apt-transport-https wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# Updates the list of available packages
sudo apt-get update
# Installs the latest OSS release:
sudo apt-get install grafana
# Installs the latest Enterprise release:
sudo apt-get install grafana-enterprise
systemctl restart grafana-server
systemctl enable grafana-server.service

echo "======================================="
echo " ZABBIX 7.4 + TIMESCALEDB INSTALADO "
echo " Acesse: http://IP_DO_SERVIDOR/zabbix "
echo "======================================="
