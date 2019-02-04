var command = process.argv[process.argv.length-1];
var childProcess = require('child_process');

var lastOutput = undefined;
var run = ()=>{
  var output = childProcess.execSync(command)+'';
  if(output!==lastOutput){
    console.log('-->',new Date())
    console.log(output);
    lastOutput = output;
  }
}

setInterval(run,5000);
run()