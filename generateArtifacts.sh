#!/bin/bash
# this script is supposed to run on a machine with hyperledger tools installed, or using docker like:
# docker run -it -v=$(pwd)/artifacts/channel:/work -w=/work --network=cc_network  hyperledger/fabric-tools bash

# cd ./artifacts/channel
# rm -r crypto-config

# #create the certifiction
# cryptogen generate --config=./cryptogen.yaml

# # create the the entity
# configtxgen -profile OneOrgsChannel -channelID confighubchannel -outputCreateChannelTx confighubchannel.tx --configPath .


# cd ./crypto-config/peerOrganizations/org1.cc.com/ca
# file=$(ls *_sk)
# mv "${file}" org1ca_sk
# cd ../../../..

# cd ./crypto-config/peerOrganizations/org1.cc.com/users/Admin@org1.cc.com/msp/keystore/
# file=$(ls *_sk)
# mv "${file}" org1ca_sk
# cd ../../../../../../..

# cd ./crypto-config/ordererOrganizations/cc.com/ca
# file=$(ls *_sk)
# mv "${file}" ordererca_sk
# cd ../../../..

# # create the genersis block
# configtxgen -profile OneOrgsOrdererGenesis -outputBlock ./genesis.block --configPath .

# cd ../..

export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=confighubchannel

# cd ./artifacts/channel

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

echo "----------";
echo $PWD
# generate crypto material
cryptogen generate --config=./cryptogen.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile OneOrgChannel -outputCreateChannelTx ./config/confighubchannel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
