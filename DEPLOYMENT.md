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

## Emergency

### Scripts

### Makefile

Remember to specify the networks needed on the Makefile.

- `make PROD=true LEDGER=true`:
- `make PROD=true LEDGER=true`:
- `make PROD=true LEDGER=true`:


## CCC

### Scripts

### Makefile

Remember to specify the networks needed on the Makefile.

- `make PROD=true LEDGER=true`:
- `make PROD=true LEDGER=true`:
- `make PROD=true LEDGER=true`:


## Access Control

The access control scripts consists on deploying the GranularGuardian contract. For this you will need to specify:

- DEFAULT_ADMIN: This role can set other roles, so should be granted to the executor lvl 1.
- RETRY_GUARDIAN: This role can retry transactions and envelopes. Should be granted to entity with expertise of the system. Normally granted to BGD guardian.
- SOLVE_EMERGENCY_GUARDIAN: This role can change ccc configuration on emergency. Should be granted to the Aave Governance guardian.

### Scripts

To correctly deploy the Granular Guardian you will need to add the network script to:
(These scripts depend on Governance (executor) to be deployed beforehand. It also needs CCC to be deployed, as GG is directly tied with it).

- [DeployGranularGuardian.s.sol](./scripts/access_control/DeployGranularGuardian.s.sol): Base script that calls the granular guardian base deployment script, passing the CCC.
- [GranularGuardianNetworkDeploys.s.sol](./scripts/access_control/network_scripts/GranularGuardianNetworkDeploys.s.sol): Script file where the network scripts are added. Here you need to define the different addresses for the different roles needed.

### Makefile

Remember to specify the networks needed on the Makefile.

- `make deploy_ccc_granular_guardian PROD=true LEDGER=true`: deploy granular guardian.

## Adapters

There is one Adapter script for every bridge provider integration. For L2 there is the native network adapter (which uses the network native bridging), and for other networks, we have 3rd party bridge providers (CCIP, LZ, HL, Wormhole) which can be used for multiple networks at the same time. On these, you will need to make sure the bridging path is supported (by the provider, and configured in the contract side).
It is important to note that the adapters need the origin ccc address to be able to accept messages, and the current CCC address to deliver the messages received.
For every adapter there can be extra configurations needed, like the GasLimit to be paid on message delivery (in destination network), or different addresses of the bridge providers (used for provider communication).

### Setters

Once adapters are deployed, the need to be set on both sides of the path, so that the networks are correctly connected.
- To set the sender adapters, you have to set the pair (origin / destination) adapters, so that CCC knows where to send the messages.
- To receive messages, you need to set the receiver adapters (which need the origin CCC to verify that the message has correct origin).

### Scripts

The scripts to deploy the bridge adapters, and set them on CCC are located here:
(The adapters depend on having deployed CCC in current and origin chain beforehand).

- [Adapters](./scripts/adapters/): folder containing the adapter deploying scripts.
- [Set_CCF_Sender_Adapters.s.sol](./scripts/ccc/Set_CCF_Sender_Adapters.s.sol): Script that sets the pair of origin / destination adapters, enabling sending of messages from origin network to destination network.
- [Set_CCR_Receivers_Adapters.s.sol](./scripts/ccc/Set_CCR_Receivers_Adapters.s.sol): Scripts that sets the receiver adapters. These adapters need the correct origin CCC to enable receiving messages from the specified network.

### Makefile

Remember to specify the networks needed on the Makefile.

- `make deploy-optimism-adapters PROD=true LEDGER=true`: deploy optimism bridge adapter (There is one make command for each adapter).
- `make set-ccf-sender-adapters PROD=true LEDGER=true`: set sender adapters. Currently we only need to set adapters on Ethereum, and the voting chains.
- `make set-ccr-receiver-adapters PROD=true LEDGER=true`: set receiver adapters. All networks should have receiver adapters (either to receive voting results, voting start messages, or payload execution messages).

Remember that for communication to work between two networks, you have to deploy the adapter on the origin network and the destination network.

## Payloads

### Scripts

### Tests

### Diffs

### Makefile

Remember to specify the networks needed on the Makefile.

- `make PROD=true LEDGER=true`:
- `make PROD=true LEDGER=true`:
- `make PROD=true LEDGER=true`: