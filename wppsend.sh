curl --request POST \
  --url http://api.mv2.solutions:9009/sistema/sendText \
  --header 'Content-Type: application/json' \
  --data '{
        "AuthorizationToken": "rFqmeBuHlaq48IhMH7cuyMRhuDyU8W2lFClEx0",
        "SessionName": "rFqmeBuHlaq48IhMH7cuyMRhuDyU8W2lFClEx0",
        "phonefull":"+55'$1'",
        "msg":"'"$2"'"
}'
