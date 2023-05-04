/** @type import('hardhat/config').HardhatUserConfig */
const fs = require("fs");

require("@nomicfoundation/hardhat-foundry");
require("hardhat-diamond-abi");

task('diamondABI', 'Generates ABI file for diamond, includes all ABIs of facets and subdirectories', async () => {
  var walk = function (dir) {
    var results = [];
    var list = fs.readdirSync(dir);
    list.forEach(function (file) {
      file = dir + '/' + file;
      var stat = fs.statSync(file);
      if (stat && stat.isDirectory()) {
        /* Recurse into a subdirectory */
        results = results.concat(walk(file));
      } else {
        /* Is a file */
        results.push(file.substring(1));
      }
    });
    return results;
  }

  const basePath = '/src/infinity/facets'
  let files = walk('.' + basePath)
  let abi = []
  for (var file of files) {
    var jsonFile
    if (file.includes('Facet')) {
      var baseName = /[^/]*$/.exec(file)[0];
      jsonFile = baseName.replace('sol', 'json');
      let json = fs.readFileSync(`./artifacts${file}/${jsonFile}`)

      json = JSON.parse(json)
      abi.push(...json.abi)
    }
  }
  abi = JSON.stringify(abi.filter((item, pos) => abi.map((a) => a.name).indexOf(item.name) == pos), null, 4)
  fs.writeFileSync('./abi/KlimaInfinity.json', abi)
  console.log('ABI written to abi/KlimaInfinity.json')
})

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }, {
        version: "0.8.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.7.5",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  }
};
