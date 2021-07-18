require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "localhost",
  networks: {
    hardhat: {},
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/25ef01a5beaa424785dd92820a5a8cb5",
      accounts: [
        "f23ccde243586e0c97c75d792a11aa8f5e74170e223f4ceb27b8288d9ba7671d",
      ],
      saveDeployments: true,
    },
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
