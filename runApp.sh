#!/bin/bash

function restartNetwork() {
  echo

  #teardown the network and clean the containers and intermediate images
  docker-compose -f ./artifacts/docker-compose.yaml down


  #Cleanup the stores
  rm -rf ./fabric-client-kv-org*

  #Start the network
  docker-compose -f ./artifacts/docker-compose.yaml up -d
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

docker run -it -v=$(pwd):/work -w=/work --network=artifacts_default  hyperledger/fabric-tools bash ./generateArtifacts.sh

docker ps -a | grep -v 'NAMES'| awk '{print $1}'|xargs docker rm -f
docker volume ls -qf dangling=true | xargs docker volume rm
docker volume prune -f
node ./scripts/sleep.js 50

restartNetwork

# installNodeModules
# PORT=4000 node app
