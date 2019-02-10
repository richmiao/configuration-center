#!/bin/bash

function restartNetwork() {
  echo

  #teardown the network and clean the containers and intermediate images
  docker-compose -f ./docker-compose.yaml down


  #Cleanup the stores
  rm -rf ./fabric-client-kv-org*

  #Start the network
  docker-compose -f ./docker-compose.yaml up -d
  echo
}

function installNodeModules() {
  echo
  if [ -d node_modules ]; then
    echo "============== node modules installed already ============="
  else
    echo "============== Installing node modules ============="
    npm install
  fi
  echo
}

# docker run -it -v=$(pwd):/work -w=/work --network=cc_network  hyperledger/fabric-tools bash ./generateArtifacts.sh

# docker ps -a | grep -v 'NAMES'| awk '{print $1}'|xargs docker rm -f
# docker volume ls -qf dangling=true | xargs docker volume rm
# docker volume prune -f
# node ./scripts/sleep.js 20

docker rm -f $(docker ps -aq)

restartNetwork

node ./scripts/sleep.js 40

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.cc.com/msp" peer0.org1.cc.com peer channel create -o orderer.cc.com:7050 -c confighubchannel -f /etc/hyperledger/configtx/confighubchannel.tx
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.cc.com/msp" peer0.org1.cc.com peer channel join -b confighubchannel.block


# node ./scripts/sleep.js 20

# install and initialize chaincode after channel created
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.cc.com/users/Admin@org1.cc.com/msp" cli peer chaincode install -n configurationCC -v 1.0 -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.cc.com/users/Admin@org1.cc.com/msp" cli peer chaincode instantiate -o orderer.cc.com:7050 -C confighubchannel -n configurationCC -l "$CC_RUNTIME_LANGUAGE" -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.cc.com/users/Admin@org1.cc.com/msp" cli peer chaincode invoke -o orderer.cc.com:7050 -C confighubchannel -n configurationCC -c '{"function":"initLedger","Args":[]}'


# installNodeModules
# PORT=4000 node app
