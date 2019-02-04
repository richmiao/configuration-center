const superstruct = require('superstruct');

module.exports.createCollection = function(channelName, chaincodeName){
  // Todo: load the chaincode file
  // todo: call install
  // todo: call instantiate
  // we want to use node.js chaincode.
}

/**
 * @param {String} channelName
 * @param {String} chaincodeName
 * @param {object} scheema should be a superstruct schema
 */
module.exports.createModel = function(channelName, chaincodeName, scheema){

  const testModel = superstruct(scheema);

  const model =  {

    async find(query){
      // todo: query chaincode
    },

    findOne: (query)=>model.find().then(list=>list[0]),

    async insert(items) {
      if(!Array.isArray(items))items = [items];
      items.forEach(testModel);
      // todo: insert
    }
  };
  return model;
}