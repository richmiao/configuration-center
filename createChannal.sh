#!/bin/bash

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peer/msp" peer0.org1.cc.com peer channel create -o orderer.cc.com:7050 -c confighubchannel -f /etc/hyperledger/configtx/confighubchannel.tx
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peer/msp" peer0.org1.cc.com peer channel join -b confighubchannel.block


node ./scripts/sleep.js 20

# install and initialize chaincode after channel created
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peer/msp" cli peer chaincode install -n configurationCC -v 1.0 -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peer/msp" cli peer chaincode instantiate -o orderer.cc.com:7050 -C confighubchannel -n configurationCC -l "$CC_RUNTIME_LANGUAGE" -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peer/msp" cli peer chaincode invoke -o orderer.cc.com:7050 -C confighubchannel -n configurationCC -c '{"function":"initLedger","Args":[]}'


# installNodeModules
# PORT=4000 node app
