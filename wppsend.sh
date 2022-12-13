curl --request POST \
  --url http://100.74.15.4:9001/sistema/sendText \
  --header 'Content-Type: application/json' \
  --data '{
        "AuthorizationToken": "rFqmeBuHlaq48IhMH7cuyMRhuDyU8W2lFClEx0",
        "SessionName": "Mv2",
        "phonefull":"+55'$1'",
        "msg":"'"$2"'"
}'
