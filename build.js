// this build script is made to run forge build and forge doc to build the solidity contract doc html files and then vercel can deploy them

const { exec } = require('child_process');

exec('forge doc --build', (error, stdout, stderr) => {
  if (error) {
    console.error(`exec error: ${error}`);
    return;
  }
  console.log(`stdout: ${stdout}`);
  console.error(`stderr: ${stderr}`);
});