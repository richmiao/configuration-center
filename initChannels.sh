

curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/json" \
  -d '{"username":"tobias","orgname":"org1"}'

echo create channel
curl -s -X POST \
  http://localhost:4000/channels \
  -H "content-type: application/json" \
  -d '{
	"channelName":"confighubchannel",
	"channelConfigPath":"../artifacts/channel/confighubchannel.tx"
}'

echo join channel
curl -s -X POST \
  http://localhost:4000/channels/confighubchannel/peers \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com"]
}'

echo "install chaincode"
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org1.example.com\"],
	\"chaincodeName\":\"users\",
	\"chaincodePath\":\"collectionChaincodeGO\",
	\"chaincodeType\": \"golang\",
	\"chaincodeVersion\":\"v1\"
}"

echo "Instantiate chaincode"
curl -s -X POST \
  http://localhost:4000/channels/confighubchannel/chaincodes \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org1.example.com\"],
	\"chaincodeName\":\"users\",
	\"chaincodeVersion\":\"v1\",
	\"chaincodeType\": \"golang\",
	\"args\":[\"\"]
}"