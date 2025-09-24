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



custom_ethereum := --with-gas-price 500000000 # 0.5 gwei
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
 --rpc-url $(if $(PROD),$(2),$(2)-testnet) --broadcast --verify --legacy -vvvv \
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
deploy-initial:
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

deploy-mantle-adapters:
	$(call deploy_fn,adapters/DeployMantleAdapter,ethereum mantle)

deploy-ink-adapters:
	$(call deploy_fn,adapters/DeployInkAdapter,ethereum ink)

deploy-soneium-adapters:
	$(call deploy_fn,adapters/DeploySoneiumAdapter,soneium ethereum)

deploy-bob-adapters:
	$(call deploy_fn,adapters/DeployBobAdapter,ethereum bob)

## Set sender bridge dapters. Only eth pol avax are needed as other networks will only receive
set-ccf-sender-adapters:
	$(call deploy_fn,ccc/Set_CCF_Sender_Adapters,ethereum)

# Set the bridge adapters allowed to receive messages
set-ccr-receiver-adapters:
	$(call deploy_fn,ccc/Set_CCR_Receivers_Adapters,ethereum polygon avalanche binance arbitrum optimism base metis gnosis zkevm)

# Sets the required confirmations
set-ccr-confirmations:
	$(call deploy_fn,CCC/Set_CCR_Confirmations,ethereum polygon avalanche optimism arbitrum metis base binance gnosis zkevm)


# ------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- ACCESS CONTROL SCRIPTS ---------------------------------------------------------

deploy_ccc_granular_guardian:
	$(call deploy_fn,access_control/network_scripts/GranularGuardianNetworkDeploys,plasma)

# ------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- HELPER SCRIPTS ---------------------------------------------------------
remove-bridge-adapters:
	$(call deploy_fn,helpers/RemoveBridgeAdapters,celo)

send-direct-message:
	$(call deploy_fn,helpers/Send_Direct_CCMessage,ethereum)

deploy_mock_destination:
	$(call deploy_fn,helpers/Deploy_Mock_destination,plasma)

set-approved-ccf-senders:
	$(call deploy_fn,helpers/Set_Approved_Senders,ethereum)

send-message:
	@$(call deploy_fn,helpers/Testnet_ForwardMessage,ethereum,Testnet_ForwardMessage)

send-message-via-adapter:
	$(call deploy_fn,helpers/Send_Message_Via_Adapter,ethereum)

deploy-new-path-payload:
	$(call deploy_fn,payloads/adapters/ethereum/Network_Deployments,ethereum)

update-owners-and-guardians:
	$(call deploy_fn,helpers/Update_Ownership,zksync)

update-ccc-permissions:
	$(call deploy_fn,helpers/UpdateCCCPermissions,plasma)
