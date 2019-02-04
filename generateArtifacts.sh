#!/bin/bash
# this script is supposed to run on a machine with hyperledger tools installed, or using docker like:
# docker run -it -v=$(pwd)/artifacts/channel:/work -w=/work --network=artifacts_default  hyperledger/fabric-tools bash

cd ./artifacts/channel
rm -r crypto-config

cryptogen generate --config=./cryptogen.yaml
configtxgen -profile OneOrgsChannel -channelID confighubchannel -outputCreateChannelTx confighubchannel.tx --configPath .


cd ./crypto-config/peerOrganizations/org1.cc.com/ca
file=$(ls *_sk)
mv "${file}" org1ca_sk
cd ../../../..

cd ./crypto-config/peerOrganizations/org1.cc.com/users/Admin@org1.cc.com/msp/keystore/
file=$(ls *_sk)
mv "${file}" org1ca_sk
cd ../../../../../../..

cd ./crypto-config/ordererOrganizations/cc.com/ca
file=$(ls *_sk)
mv "${file}" ordererca_sk
cd ../../../..

configtxgen -profile OneOrgsOrdererGenesis -outputBlock ./genesis.block --configPath .

cd ../..