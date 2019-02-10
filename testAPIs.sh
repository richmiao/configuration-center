#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done


CC_SRC_PATH="$PWD/artifacts/src/gosrc"


echo "POST request Enroll on org1  ..."
echo
org1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=admin&orgname=org1&')
echo $org1_TOKEN
org1_TOKEN=$(echo $org1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "org1 token is $org1_TOKEN"
echo

# echo "POST request Enroll on Org2 ..."
# echo
# ORG2_TOKEN=$(curl -s -X POST \
#   http://localhost:4000/users \
#   -H "content-type: application/x-www-form-urlencoded" \
#   -d 'username=Barry&orgname=Org2')
# echo $ORG2_TOKEN
# ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
# echo
# echo "ORG2 token is $ORG2_TOKEN"
# echo
# echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"confighubchannel",
	"channelConfigPath":"../artifacts/channel/ConfigHubChannel.tx"
}'
echo
echo
sleep 5
echo "POST request Join channel on org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/confighubchannel/peers \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.cc.com"]
}'
echo
echo

# echo "POST request Join channel on Org2"
# echo
# curl -s -X POST \
#   http://localhost:4000/channels/confighubchannel/peers \
#   -H "authorization: Bearer $ORG2_TOKEN" \
#   -H "content-type: application/json" \
#   -d '{
# 	"peers": ["peer0.org2.cc.com","peer1.org2.cc.com"]
# }'
# echo
# echo

echo "POST request Update anchor peers on org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/confighubchannel/anchorpeers \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/Org1MSPanchors.tx"
}'
echo
echo

# echo "POST request Update anchor peers on Org2"
# echo
# curl -s -X POST \
#   http://localhost:4000/channels/confighubchannel/anchorpeers \
#   -H "authorization: Bearer $ORG2_TOKEN" \
#   -H "content-type: application/json" \
#   -d '{
# 	"configUpdatePath":"../artifacts/channel/Org2MSPanchors.tx"
# }'
# echo
# echo

echo "POST Install chaincode on org1"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org1.cc.com\"],
	\"chaincodeName\":\"configurationCC\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

# echo "POST Install chaincode on Org2"
# echo
# curl -s -X POST \
#   http://localhost:4000/chaincodes \
#   -H "authorization: Bearer $ORG2_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
# 	\"peers\": [\"peer0.org2.cc.com\",\"peer1.org2.cc.com\"],
# 	\"chaincodeName\":\"configurationCC\",
# 	\"chaincodePath\":\"$CC_SRC_PATH\",
# 	\"chaincodeType\": \"$LANGUAGE\",
# 	\"chaincodeVersion\":\"v0\"
# }"
# echo
# echo

echo "POST instantiate chaincode on org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/confighubchannel/chaincodes \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"configurationCC\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
echo
echo

# echo "POST invoke chaincode on peers of org1 and Org2"
# echo
# TRX_ID=$(curl -s -X POST \
#   http://localhost:4000/channels/confighubchannel/chaincodes/configurationCC \
#   -H "authorization: Bearer $org1_TOKEN" \
#   -H "content-type: application/json" \
#   -d '{
# 	"peers": ["peer0.org1.cc.com","peer0.org2.cc.com"],
# 	"fcn":"move",
# 	"args":["a","b","10"]
# }')
# echo "Transaction ID is $TRX_ID"
# echo
# echo

echo "GET query chaincode on peer0 of org1"
echo
curl -s -X GET \
  "http://localhost:4000/channels/confighubchannel/chaincodes/configurationCC?peer=peer0.org1.cc.com&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Block by blockNumber"
echo
BLOCK_INFO=$(curl -s -X GET \
  "http://localhost:4000/channels/confighubchannel/blocks/1?peer=peer0.org1.cc.com" \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json")
echo $BLOCK_INFO
# Assign previvious block hash to HASH
HASH=$(echo $BLOCK_INFO | jq -r ".header.previous_hash")
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/confighubchannel/transactions/$TRX_ID?peer=peer0.org1.cc.com \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "GET query Block by Hash - Hash is $HASH"
echo
curl -s -X GET \
  "http://localhost:4000/channels/confighubchannel/blocks?hash=$HASH&peer=peer0.org1.cc.com" \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "cache-control: no-cache" \
  -H "content-type: application/json" \
  -H "x-access-token: $org1_TOKEN"
echo
echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/confighubchannel?peer=peer0.org1.cc.com" \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.cc.com" \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/confighubchannel/chaincodes?peer=peer0.org1.cc.com" \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.org1.cc.com" \
  -H "authorization: Bearer $org1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
