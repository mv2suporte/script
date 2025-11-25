#!/bin/bash
# evolution_whatsapp.sh

EVOLUTION_URL="http://apiwhatsapp.mv2solutions.com.br"    	# exemplo: http://localhost:8081
INSTANCE="monitoramento"                      				# ex: device1
TOKEN="5B6074DCC8E2-4689-B906-FE8BB5C65738"					# token do device na evolution

NUMBER="$1"     # número do WhatsApp em formato internacional (5511999999999)
MESSAGE="$2"    # mensagem enviada pelo Zabbix

curl -X POST "$EVOLUTION_URL/message/sendText/$INSTANCE" \
     -H "Content-Type: application/json" \
     -H "apikey: $TOKEN" \
     -d "{
           \"number\": \"$NUMBER\",
           \"text\": \"$MESSAGE\"
         }"
