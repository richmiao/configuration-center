/**
 * mdoels will be associated with a specific chaincode. This chaincode will provide MongoLike Capability.
 * 
 */
const CONFIG = require('../../config.json');
const model =require('../lib/model');
const CHANNEL_NAME = CONFIG.channelName;

// todo: test if Chaincode exist and create it

const userModel = model.createModel(CHANNEL_NAME, 'users',{
  name:'string',
  password:'string', // sha512 hash
  creator: 'string', // other userId, user don't register themself, they get registered by someone
  mail: 'string',
  // create & edit times will be in the blockchain(could be stored for convenience and optimizations)
  
});

module.exports.userModel = userModel;