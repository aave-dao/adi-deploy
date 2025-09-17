# Deployment of the Aave Delivery Infrastructure contracts

In this document we will specify the different steps needed to deploy the different parts of the Aave Delivery Infrastructure (aDI), consisting on:

- [Access Control](./DEPLOYMENT.md)
- [Adapters](./DEPLOYMENT.md)
- [CCC](./DEPLOYMENT.md)
- [Emergency](./DEPLOYMENT.md)

All of these scripts inherit from the base scripts found on the [Aave Delivery Infrastucture](https://github.com/aave-dao/aave-delivery-infrastructure) repository. An explanation on how they work can be found [here](https://github.com/aave-dao/aave-delivery-infrastructure/blob/main/scripts/README.md)

In this repository we can also find the scripts to deploy the necessary payloads to maintain and update the aDI system:

- [Payloads](./DEPLOYMENT.md)


## Setup

There are a few things to take into account that will need to be updated / modified for deployments on different networks.

- *.env*: copy [.env.example](./.env.example) into `.env` file, and fill it. the private key is only need if you want to deploy with it. If not you only need to fill `MNEMONIC_INDEX` and `LEDGER_SENDER` (specified later on how to choose between the two ways of deployment)
- *[foundry.toml](./foundry.toml)*: when adding a new network, you should also add the respective definitions (rpc_endpoints and etherscan). Under the etherscan section you should only add the network configuration if its not supported by etherscan. If there is a network that needs special configuration, add it there also, under the network profile.
- *scripts*: These can be found in the folder [scripts](./scripts/). Here you will find the deployment scripts needed for the different parts of the system.
If you are adding a new network, you will first need to double check that the nework is added in [Solidity Utils](https://github.com/bgd-labs/solidity-utils/blob/main/src/contracts/utils/ChainHelpers.sol) repository, and then add a new network script in [InitialDeployment.s.sol](). When using the scripts for the deployments, they will get the necessary addresses from the generated json files under [deployments](./deployments/) folder, so it is necessary to follow the strict deployment order, that will be specified later. After deployment, the scripts save the new deployed addresses in the mentioned json files.
- *deployments*: The [deployments](./deployments/) folder contains the deployed addresses for every network. Its important to take into account that the json files will be modified with the script execution or simulation, so if there is a simulation but execution fails, the addresses will be modified.
- *Makefile*: This can be found [here](./Makefile). It has the commands to be able to deploy each smart contract for the selected network. If you need to deploy any of the smart contracts to a new network, (after you have added the necessary network scripts), you just need to change the network name in the necessary command and execute it.
You can deploy using a private key or a ledger by adding `LEDGER=true` to the execution command. If you want to deploy into a mainnet network, you would need to add: `PROD=true`. You can also set the specific gwei amount to pay for the transaction.

You can see here an example of executing the first command that you need that will generate the specified network addresses json:

```
deploy-initial:
	$(call deploy_fn,InitialDeployments,ethereum polygon avalanche arbitrum optimism metis base binance gnosis)
```
In this case you would need to only have the network that you want to deploy on. If you leave multiple networks in the command, it will deploy on all of them sequentially.

Execution command would look like this: `make deploy-initial PROD=true LEDGER=true`

### Notes

- It is very important to follow the order specified for the deployments. As there are some contracts that need addresses of previously deployed contracts (even on other networks) for correct communication.

## Initial Scripts

As previously said, you should add the new network script to `InitialDeployments` and execute the initial script only for new network (as doing for existing ones would rewrite the addresses json of the specified network with address(0)). This will create a new addresses json for the new network.

- execution command: `make deploy-initial PROD=true LEDGER=true` 
