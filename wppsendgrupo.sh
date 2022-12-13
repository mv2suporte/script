curl --request POST \
  --url http://100.74.15.4:9001/sistema/sendTextGrupo \
  --header 'Content-Type: application/json' \
  --data '{
        "AuthorizationToken": "rFqmeBuHlaq48IhMH7cuyMRhuDyU8W2lFClEx0",
        "SessionName": "Mv2",
        "groupId":"'$1'",
        "msg":"'"$2"'"
}'
