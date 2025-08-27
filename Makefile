# To avoid make printing out commands and potentially exposing private keys, prepend an "@" to the command.
# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes --via-ir
test   :; forge test -vvv

# ---------------------------------------------- BASE SCRIPT CONFIGURATION ---------------------------------------------

BASE_LEDGER = --ledger --mnemonic-indexes $(MNEMONIC_INDEX) --sender $(LEDGER_SENDER)
BASE_KEY = --private-key ${PRIVATE_KEY}



custom_ethereum := --with-gas-price 2000000000 # 53 gwei
#custom_polygon :=  --with-gas-price 190000000000 # 560 gwei
#custom_avalanche := --with-gas-price 27000000000 # 27 gwei
#custom_metis-testnet := --legacy --verifier-url https://goerli.explorer.metisdevops.link/api/
#custom_metis := --verifier-url  https://api.routescan.io/v2/network/mainnet/evm/1088/etherscan
#custom_scroll-testnet := --legacy --with-gas-price 1000000000 # 1 gwei
custom_zksync := --zksync
custom_linea-testnet :=  --legacy --with-gas-price 27000000000 --force # 1 gwei
custom_linea :=  --with-gas-price 1000000000 --force # 1 gwei
# custom_bob :=  --with-gas-price 100000000 --force # 0.1 gwei
custom_ethereum-testnet :=  --legacy --with-gas-price 27000000000 --force # 1 gwei

# params:
#  1 - path/file_name
#  2 - network name
#  3 - script to call if not the same as network name (optional)
#  to define custom params per network add vars custom_network-name
#  to use ledger, set LEDGER=true to env
#  default to testnet deployment, to run production, set PROD=true to env
define deploy_single_fn
forge script \
 scripts/$(1).s.sol:$(if $(3),$(if $(PROD),$(3),$(3)_testnet),$(shell UP=$(if $(PROD),$(2),$(2)_testnet); echo $${UP} | perl -nE 'say ucfirst')) \
 --rpc-url $(if $(PROD),$(2),$(2)-testnet) --broadcast --verify -vvvv \
 $(if $(LEDGER),$(BASE_LEDGER),$(BASE_KEY)) \
 $(custom_$(if $(PROD),$(2),$(2)-testnet))

endef

# catapulta
#define deploy_single_fn
#npx catapulta@latest script \
# scripts/$(1).s.sol:$(if $(3),$(3),$(shell UP=$(if $(PROD),$(2),$(2)_testnet); echo $${UP} | perl -nE 'say ucfirst')) \
# --network $(2) --slow --skip-git \
# $(if $(LEDGER),$(BASE_LEDGER),$(BASE_KEY)) \
# $(custom_$(if $(PROD),$(2),$(2)-testnet))
#
#endef

define deploy_fn
 $(foreach network,$(2),$(call deploy_single_fn,$(1),$(network),$(3)))
endef

# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- PRODUCTION DEPLOYMENT SCRIPTS ---------------------------------------------------------

# deploy emergency registry
deploy-emergency-registry:
	$(call deploy_fn,Deploy_EmergencyRegistry,ethereum)

# Deploy Proxy Factories on all networks
deploy-proxy-factory:
	$(call deploy_fn,InitialDeployments,ethereum avalanche polygon optimism arbitrum metis base binance gnosis zkevm)

# Deploy Cross Chain Infra on all networks
deploy-cross-chain-infra:
	$(call deploy_fn,ccc/Deploy_CCC,ethereum avalanche polygon optimism arbitrum metis base binance gnosis zkevm)

## Deploy CCIP bridge adapters on all networks
deploy-ccip-bridge-adapters:
	$(call deploy_fn,adapters/DeployCCIP,ethereum avalanche binance polygon binance gnosis)

## Deploy LayerZero bridge adapters on all networks
deploy-lz-bridge-adapters:
	$(call deploy_fn,adapters/DeployLZ,ethereum avalanche binance polygon binance gnosis)

## Deploy HyperLane bridge adapters on all networks
deploy-hl-bridge-adapters:
	$(call deploy_fn,adapters/DeployHL,ethereum avalanche binance polygon binance gnosis)

## Deploy SameChain adapters on ethereum
deploy-same-chain-adapters:
	$(call deploy_fn,adapters/DeploySameChainAdapter,ethereum)

deploy-optimism-adapters:
	$(call deploy_fn,adapters/DeployOpAdapter,ethereum optimism)

deploy-arbitrum-adapters:
	$(call deploy_fn,adapters/DeployArbAdapter,ethereum arbitrum)

deploy-metis-adapters:
	$(call deploy_fn,adapters/DeployMetisAdapter,ethereum metis)

deploy-polygon-adapters:
	$(call deploy_fn,adapters/DeployPolygon,ethereum polygon)

deploy-base-adapters:
	$(call deploy_fn,adapters/DeployCBaseAdapter,ethereum base)

deploy-gnosis-adapters:
	$(call deploy_fn,adapters/DeployGnosisChain,ethereum gnosis)

deploy-scroll-adapters:
	$(call deploy_fn,adapters/DeployScrollAdapter,ethereum scroll)

deploy-zkevm-adapters:
	$(call deploy_fn,adapters/DeployZkEVMAdapter,ethereum zkevm)

deploy-wormhole-adapters:
	$(call deploy_fn,adapters/DeployWormholeAdapter,ethereum celo)

deploy-zksync-adapters:
	$(call deploy_fn,adapters/DeployZkSyncAdapter,ethereum)

deploy-linea-adapters:
	$(call deploy_fn,adapters/DeployLineaAdapter,ethereum linea)

## Set sender bridge dapters. Only eth pol avax are needed as other networks will only receive
set-ccf-sender-adapters:
	$(call deploy_fn,ccc/Set_CCF_Sender_Adapters,ethereum)

# Set the bridge adapters allowed to receive messages
set-ccr-receiver-adapters:
	$(call deploy_fn,ccc/Set_CCR_Receivers_Adapters,ethereum polygon avalanche binance arbitrum optimism base metis gnosis zkevm)

# Sets the required confirmations
set-ccr-confirmations:
	$(call deploy_fn,CCC/Set_CCR_Confirmations,ethereum polygon avalanche optimism arbitrum metis base binance gnosis zkevm)

# Generate Addresses Json
write-json-addresses :; forge script scripts/WriteAddresses.s.sol:WriteDeployedAddresses -vvvv


## Deploy and configure all contracts
deploy-full:
		make deploy-proxy-factory
		make deploy-cross-chain-infra
		make deploy-ccip-bridge-adapters
		make deploy-lz-bridge-adapters
		make deploy-hl-bridge-adapters
		make deploy-same-chain-adapters
		make deploy-optimism-adapters
		make deploy-arbitrum-adapters
		make deploy-metis-adapters
		make deploy-polygon-adapters
		make set-ccf-approved-senders
		make set-ccf-sender-adapters
		make set-ccr-receiver-adapters
		make set-ccr-confirmations
		make fund-crosschain
		make write-json-addresses



# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- TESTNET DEPLOYMENT SCRIPTS ---------------------------------------------------------

# Deploy Proxy Factories on all networks
deploy-proxy-factory-test:
	$(call deploy_fn,InitialDeployments,plasma)

# Deploy Cross Chain Infra on all networks
deploy-cross-chain-infra-test:
	$(call deploy_fn,ccc/DeployCCC,bob)

## Deploy CCIP bridge adapters on all networks
deploy-ccip-bridge-adapters-test:
	$(call deploy_fn,adapters/DeployCCIPAdapter,ethereum)

## Deploy LayerZero bridge adapters on all networks
deploy-lz-bridge-adapters-test:
	$(call deploy_fn,adapters/DeployLZ,sonic)

## Deploy HyperLane bridge adapters on all networks
deploy-hl-bridge-adapters-test:
	$(call deploy_fn,adapters/DeployHL,sonic)

## Deploy SameChain adapters on ethereum
deploy-same-chain-adapters-test:
	$(call deploy_fn,adapters/DeploySameChainAdapter,ethereum)

deploy-scroll-adapters-test:
	$(call deploy_fn,adapters/DeployScrollAdapter,ethereum)

deploy-wormhole-adapters-test:
	$(call deploy_fn,adapters/DeployWormholeAdapter,ethereum)

deploy-polygon-adapters-test:
	$(call deploy_fn,adapters/DeployPolygon,ethereum)

deploy-gnosis-adapters-test:
	$(call deploy_fn,adapters/DeployGnosisChain,ethereum)

deploy-arbitrum-adapters-test:
	$(call deploy_fn,adapters/DeployArbAdapter,ethereum)

deploy-optimism-adapters-test:
	$(call deploy_fn,adapters/DeployOpAdapter,ethereum)

deploy-metis-adapters-test:
	$(call deploy_fn,adapters/DeployMetisAdapter,ethereum)

deploy-base-adapters-test:
	$(call deploy_fn,adapters/DeployCBaseAdapter,ethereum)

deploy-linea-adapters-test:
	$(call deploy_fn,adapters/DeployLineaAdapter,ethereum)

deploy-mantle-adapters-test:
	$(call deploy_fn,adapters/DeployMantleAdapter,mantle)

deploy-ink-adapters-test:
	$(call deploy_fn,adapters/DeployInkAdapter,ink)

deploy-soneium-adapters-test:
	$(call deploy_fn,adapters/DeploySoneiumAdapter,soneium ethereum)

deploy-bob-adapters-test:
	$(call deploy_fn,adapters/DeployBobAdapter,bob)

## Set sender bridge dapters. Only eth pol avax are needed as other networks will only receive
set-ccf-sender-adapters-test:
	$(call deploy_fn,ccc/Set_CCF_Sender_Adapters,ethereum)

# Set the bridge adapters allowed to receive messages
set-ccr-receiver-adapters-test:
	$(call deploy_fn,ccc/Set_CCR_Receivers_Adapters,bob)

# Sets the required confirmations
set-ccr-confirmations-test:
	$(call deploy_fn,ccc/Set_CCR_Confirmations,bob)


## Deploy and configure all contracts
deploy-full-test:
		#make deploy-proxy-factory-test
		make deploy-cross-chain-infra-test
		make deploy-ccip-bridge-adapters-test
		make deploy-lz-bridge-adapters-test
		make deploy-hl-bridge-adapters-test
		make deploy-same-chain-adapters-test
		make set-ccf-sender-adapters-test
		make set-ccr-receiver-adapters-test
		make set-ccr-confirmations-test
		make fund-crosschain-test
		make write-json-addresses



# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- HELPER SCRIPTS ---------------------------------------------------------
remove-bridge-adapters:
	$(call deploy_fn,helpers/RemoveBridgeAdapters,celo)

send-direct-message:
	$(call deploy_fn,helpers/Send_Direct_CCMessage,ethereum)

deploy_mock_destination:
	$(call deploy_fn,helpers/Deploy_Mock_destination,bob)

set-approved-ccf-senders:
	$(call deploy_fn,helpers/Set_Approved_Senders,ethereum)

send-message:
	@$(call deploy_fn,helpers/Testnet_ForwardMessage,ethereum,Testnet_ForwardMessage)

deploy_mock_ccc:
	$(call deploy_fn,helpers/mocks/Deploy_Mock_CCC,zkevm)

send-message-via-adapter:
	$(call deploy_fn,helpers/Send_Message_Via_Adapter,ethereum)

deploy_ccc_granular_guardian:
	$(call deploy_fn,access_control/network_scripts/GranularGuardianNetworkDeploys,bob)

deploy-ccc-revision-and-update:
	$(call deploy_fn,CCC/UpdateCCC,ethereum)

deploy-ccc-update-payload:
	$(call deploy_fn,helpers/UpdateCCCImpl_Payload,celo)

deploy-ccc-shuffle-payload:
	$(call deploy_fn,payloads/ccc/shuffle/Network_Deployments,metis)

deploy-new-path-payload:
	$(call deploy_fn,payloads/adapters/ethereum/Network_Deployments,ethereum)

update-owners-and-guardians:
	$(call deploy_fn,helpers/Update_Ownership,zksync)

update-ccc-permissions:
	$(call deploy_fn,helpers/UpdateCCCPermissions,bob)
