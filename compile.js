const path = require('path'),
  solc = require('solc'),
  fs = require('fs-extra'),
  buildPath = path.resolve(__dirname, 'build');

fs.removeSync(buildPath);

const contractPath = path.resolve(__dirname, 'contract', 'Escrow.sol'),
  source = fs.readFileSync(contractPath, 'utf8'),
  output = solc.compile(source, 1).contracts;

//console.log(output);

fs.ensureDirSync(buildPath);

for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, `${contract.replace(':', '')}.json`),
    output[contract]
  );
}
