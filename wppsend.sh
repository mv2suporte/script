curl --request POST \
  --url http://api.mv2.solutions:9009/message/sendText \
  --header 'AuthorizationToken: HDFTRE88776SBHGHFGYY2' \
  --header 'Content-Type: application/json' \
  --data '{
                "SessionName": "HDFTRE88776SBHGHFGYY2",
                "phonefull": "+55'$1'",
                "msg":"'"$2"'"
}'
