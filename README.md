# Docker install
wget https://raw.githubusercontent.com/mv2suporte/script/main/docker_install.sh

chmod a+x docker_install.sh

./docker_install.sh

# Zabbix install
wget https://raw.githubusercontent.com/mv2suporte/script/main/zabbix_install.sh

chmod a+x zabbix_install.sh

./zabbix_install.sh

# PhpIpam install
wget https://raw.githubusercontent.com/mv2suporte/script/main/phpipam_install.sh

chmod a+x phpipam_install.sh

./phpipam_install.sh

OBS: nano /var/www/html/phpipam/config.php

Substituir 
define('BASE', "/");

para

define('BASE', "/phpipam/");
