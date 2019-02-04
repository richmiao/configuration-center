

const { userModel }  = require('../models/userModel');


module.exports.find = (query)=>userModel.find(query).then(users=>{
  users.forEach(user => {
    delete user.password;
  });
  return users;
});
module.exports.findOne = (query)=>userModel.findOne(query).then(user=>{
  delete user.password;
  return user;
});