curl --request POST \
  --url http://api.mv2.solutions:9009/group/sendTextGrupo \
  --header 'AuthorizationToken: HDFTRE88776SBHGHFGYY2' \
  --header 'Content-Type: application/json' \
  --data '{
        "SessionName": "HDFTRE88776SBHGHFGYY2",
        "groupId":"'$1'",
        "msg":"'"$2"'"
}'
