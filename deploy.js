const HDWalletProvider = require('truffle-hdwallet-provider-privkey'),
  Web3 = require('web3'),
  provider = new HDWalletProvider(
    'RAW ETHER ACCOUNT PRIVATE KEY (WITHOUT 0x)',
    'https://rinkeby.infura.io/D3SAVJhqB6IuHvI8DAeA'
  ),
  contract = require('./build/Escrow.json'),
  web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();
  console.log(
    web3.utils.fromWei(await web3.eth.getBalance(accounts[0]), 'ether')
  );

  console.log('Attempting to deploy from account', accounts[0]);
  const result = await new web3.eth.Contract(JSON.parse(contract.interface))
    .deploy({
      data: '0x' + contract.bytecode,
      arguments: [
        '0x1d80D29D0C4AD15668BF9E8fFE99E93bdcABbDC7',
        '0x1d80D29D0C4AD15668BF9E8fFE99E93bdcABbDC7'
      ]
    })
    .send({
      from: accounts[0],
      gas: 1000000
    });
  console.log(result.options.address);
};

deploy();
