const { exec } = require('child_process');

exec('curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup && forge doc --build', (error, stdout, stderr) => {
    if (error) {
        console.error(`exec error: ${error}`);
        return;
    }
    console.log(`stdout: ${stdout}`);
    console.error(`stderr: ${stderr}`);
});