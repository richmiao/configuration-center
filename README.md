
# eventhub desktop
this project setup is originally forked from Fabric-Samples/balance-transfer. The intend is to build develop two things.
1. The configuration Hub application
2. A boilerplate that can be used to kickstart further project more quickly.

# Project
This project will setup a minimal hyperledger fabric network, with CouchDB as storrage in the peer.
The application will use the network with a single user. like a user for Mysql, where you do not give every single enduser an account,
but the endusers are handled as part of the application logic.

It will introduce a chaincode, that will allow to expose APIs, that are similar to mongoDB. As the project progress, even
Indexes will be supported.

An application should live in a single Hyperledger Fabric channel. For each Collection a new chaincode will be instantiated.
the code is actually the same souce-code file, but installed with the collection name as its name. 
This will make full use of Fabric's channel/chaincode structure. 




# changes to this project



# start this project


docker run -it -v=$(pwd)/artifacts/channel:/work -w=/work --network=artifacts_default  hyperledger/fabric-tools bash
  cryptogen generate --config=./cryptogen.yaml
  configtxgen -profile OneOrgsChannel -channelID ConfigHubChannel -outputCreateChannelTx ConfigHubChannel.tx --configPath .
  
  cd ./crypto-config/peerOrganizations/org1.example.com/ca
  file=$(ls *_sk)
  mv "${file}" org1ca_sk
  cd ../../../..

  cd ./crypto-config/ordererOrganizations/example.com/ca
  file=$(ls *_sk)
  mv "${file}" org1ca_sk
  cd ../../../..

  configtxgen -profile OneOrgsOrdererGenesis -outputBlock ./genesis.block --configPath .

  exit


./runApp.sh

docker run -it -v=$(pwd):/work -w=/work --network=artifacts_default -p=4000:4000 node bash
  export NODE_TLS_REJECT_UNAUTHORIZED=0
  npm config set strict-ssl false
  npm install 
  npm run start



# Todo's
installing native node modules can realy be a pain in the ass!!! 
it would be good if we could download prepackaged binaries

for GRPC the prebuild binaries are here:
https://node-precompiled-binaries.grpc.io/grpc/v1.14.2/node-v57-linux-x64-glibc.tar.gz


# Issues
## node.js chainode
we can not use node.js Chaincode. that would make it so much easyer to build general purpose or generic chaincodes then
using go-lang.
We can not use them, because the peer is going to create a chaincode container, that container need to install
the module x509. That module uses native components and need to download something using GYP. GYP is a tool to compile
node-modules. Usially we can set an environment variable to accept selfsifned certificates. but as the container is 
created by the peer software, we can not (in reasonable amount of time) pass that variable to that dynamic created
container. 
The problem might occur because of the office network or because of the chinese firewall.

