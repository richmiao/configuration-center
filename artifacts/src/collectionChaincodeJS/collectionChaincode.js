/*
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
*/

const shim = require('fabric-shim');
const util = require('util');

var Chaincode = class {

  /**
   * 
   * @param {shim.ChaincodeStub} stub 
   */
  async Init(stub) {
    console.info('========= example_cc Init =========');
    return shim.success()
  }
  /**
   * 
   * @param {shim.ChaincodeStub} stub 
   */
  async Invoke(stub) {
    try {
      const {fcn, params} = stub.getFunctionAndParameters();
      console.info('INVOKE:', fcn, params);
      const args = JSON.parse(params[0]);
      let method = this[fcn];
      if (!method) {
        throw new Error('no method of name:' + fcn + ' found');
      }

      console.info('\nCalling method : ' + fcn);
      let payload = await method(stub, args);
      return shim.success(Buffer.from(payload));
    } catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }
  /**
   * 
   * @param {shim.ChaincodeStub} stub 
   * @param {Object} args
   */
  async query(stub, args){
    if(!args.userId)throw new Error('missing userId');
    if(!args.query) throw new Error('missing Query');
    const results = [];
    const iterator = await stub.getQueryResult(JSON.stringify(args.query));
    for(var i of iterator){
      results.push(i);
    }
    return '['+results.join(',')+']'; // return items without parsing them
  }
  /**
   * 
   * @param {shim.ChaincodeStub} stub 
   * @param {Object} args
   */
  async insert(stub, args) {

    if(!args.userId)throw new Error('missing userId');
    if(!args.data) throw new Error('missing data');
    if(typeof args.intend === 'stirng') throw new Error('missing Intend');
    if(typeof args.data._id === 'string') throw new Error('missing _id');
    
    // untested
    const existingData = JSON.parse((await stub.getState(args.data._id)).toString());
    if(existingData){
      throw new Error('already exists');
    }

    // Write the states back to the ledger
    await stub.putState(args.data._id, Buffer.from(JSON.stringify(args.data)));

  }
  /**
   * 
   * @param {shim.ChaincodeStub} stub 
   * @param {Object} args
   */
  async edit(stub, args) {

    if(!args.userId)throw new Error('missing userId');
    if(!args.data) throw new Error('missing data');
    if(typeof args.intend === 'stirng') throw new Error('missing Intend');
    if(typeof args.data._id === 'string') throw new Error('missing _id');
    
    // untested
    const existingData = JSON.parse((await stub.getState(args.data._id)).toString());
    if(!existingData){
      throw new Error('not found');
    }

    // Write the states back to the ledger
    await stub.putState(args.data._id, Buffer.from(JSON.stringify(args.data)));

  }
  /**
   * 
   * @param {shim.ChaincodeStub} stub 
   * @param {Object} args
   */
  async delete(stub, args) {

    if(!args.userId)throw new Error('missing userId');
    if(typeof args.intend === 'stirng') throw new Error('missing Intend');
    if(typeof args.id === 'string') throw new Error('missing _id');
    
    // untested
    const existingData = JSON.parse((await stub.getState(args.id)).toString());
    if(!existingData){
      throw new Error('not found');
    }

    // Write the states back to the ledger
    await stub.putState(args.data._id, Buffer.from(JSON.stringify(args.data)));
  }
  
  //todo: implement history query

};

shim.start(new Chaincode());
