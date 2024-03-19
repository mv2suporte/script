#!/bin/bash

APIURL="https://api.anablock.net.br/domains/all?output=unbound&ipv4=127.0.0.1&ipv6=::1"
CONF="/etc/unbound/unbound.conf.d/anablock.conf"

# Baixando config no formato Unbound:
curl -s $APIURL -o $CONF

# Conferir se baixou corretamente, unifique em um arquivo temporario:
(
    cat /etc/unbound/unbound.conf;
    echo "server:";
    cat /etc/unbound/unbound.conf.d/anablock.conf;
)  > /tmp/unbound-test.conf

# Testar:
unbound-checkconf /tmp/unbound-test.conf
