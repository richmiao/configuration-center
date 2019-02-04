var router = require('express').Router();
const CONFIG = require('../../config.json');
const _ = require('underscore');
const userController = require('../controller/userController');


module.exports = router;

module.exports.authMiddleware = async(req, res, next)=>{
  var args = {...req.query,...req.body};
  if(typeof args.username ==='string' && typeof args.password === 'string'){
    var user = await authenticateCredentials(args.username, args.password);
    if(!user) throw new Error('wrong user credentials');
  }
  // todo: 
}

authenticateCredentials = async (username,password)=>{
  var admin = _.where(CONFIG.admins,{username:username});
  if(admin){
    return password === admin.secret ? admin : undefined;
  }
  //Todo: authenticate against User collection in chaincode
  return false;
}
