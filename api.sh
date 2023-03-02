#!/bin/bash
rm /usr/lib/zabbix/alertscripts/wppsend*
wget -c -P /usr/lib/zabbix/alertscripts https://raw.githubusercontent.com/mv2suporte/script/main/wppsendgrupo.sh /usr/lib/zabbix/alertscripts
wget -c -P /usr/lib/zabbix/alertscripts https://raw.githubusercontent.com/mv2suporte/script/main/wppsend.sh /usr/lib/zabbix/alertscripts
chmod a+x /usr/lib/zabbix/alertscripts/wppsendgrupo.sh
chmod a+x /usr/lib/zabbix/alertscripts/wppsend.sh