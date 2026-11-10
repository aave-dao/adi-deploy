#!/usr/bin/env bash
# Deploys the LayerZero replacement adapters, then the governance payloads.
# Each step is simulated first and only broadcast after an explicit "y".
#
#   EXPECTED_SENDER=0x... ./scripts/replace_lz.sh adapters
#   EXPECTED_SENDER=0x... ./scripts/replace_lz.sh payloads
set -euo pipefail

PHASE="${1:-}"
ACCOUNT_NAME="${ACCOUNT_NAME:-claude}"
: "${EXPECTED_SENDER:?set EXPECTED_SENDER to the address of the $ACCOUNT_NAME keystore account}"
export FOUNDRY_PROFILE=default

cd "$(dirname "$0")/.."

# <script:contract> <rpc alias> <deployments json> <key the script records>
ADAPTER_STEPS=(
  "scripts/adapters/DeployWormholeExecutor.s.sol:Ethereum ethereum ethereum wormholeExecutorAdapter"
  "scripts/adapters/DeployCCIPAdapter.s.sol:Ethereum_Gnosis ethereum ethereum ccipAdapter"
  "scripts/adapters/DeployWormholeExecutor.s.sol:Polygon polygon polygon wormholeExecutorAdapter"
  "scripts/adapters/DeployWormholeExecutor.s.sol:Avalanche avalanche avalanche wormholeExecutorAdapter"
  "scripts/adapters/DeployWormholeExecutor.s.sol:Binance binance binance wormholeExecutorAdapter"
  "scripts/adapters/DeployWormholeExecutor.s.sol:Monad monad monad wormholeExecutorAdapter"
  "scripts/adapters/DeployCCIPAdapter.s.sol:Gnosis gnosis gnosis ccipAdapter"
)

# Ethereum last: its payload reads every remote adapter from deployments/*.json
PAYLOAD_STEPS=(
  "scripts/payloads/adapters/replace_lz/Network_Deployments.s.sol:Polygon polygon"
  "scripts/payloads/adapters/replace_lz/Network_Deployments.s.sol:Avalanche avalanche"
  "scripts/payloads/adapters/replace_lz/Network_Deployments.s.sol:Binance binance"
  "scripts/payloads/adapters/replace_lz/Network_Deployments.s.sol:Monad monad"
  "scripts/payloads/adapters/replace_lz/Network_Deployments.s.sol:Gnosis gnosis"
  "scripts/payloads/adapters/replace_lz/Network_Deployments.s.sol:Ethereum ethereum"
)

case "$PHASE" in
  adapters) STEPS=("${ADAPTER_STEPS[@]}") ;;
  payloads) STEPS=("${PAYLOAD_STEPS[@]}") ;;
  *) echo "usage: $0 adapters|payloads" >&2; exit 1 ;;
esac

signer=$(cast wallet address --account "$ACCOUNT_NAME")
if [ "$(echo "$signer" | tr '[:upper:]' '[:lower:]')" != "$(echo "$EXPECTED_SENDER" | tr '[:upper:]' '[:lower:]')" ]; then
  echo "keystore $ACCOUNT_NAME resolves to $signer, expected $EXPECTED_SENDER" >&2
  exit 1
fi
echo "signer: $signer"

for step in "${STEPS[@]}"; do
  read -r target network json_name json_key <<<"$step"
  echo
  echo "== $target on $network (balance: $(cast balance "$signer" --ether --rpc-url "$network"))"

  # simulation only, no key involved. The scripts persist addresses even when simulating, so restore
  # deployments/ afterwards: only a broadcast may record an address the payload scripts will trust
  snapshot=$(mktemp -d)
  cp deployments/*.json "$snapshot/"
  status=0
  forge script "$target" --rpc-url "$network" --sender "$signer" -vvv || status=$?
  cp "$snapshot"/*.json deployments/
  rm -r "$snapshot"
  if [ "$status" -ne 0 ]; then
    echo "simulation failed for $target on $network" >&2
    exit "$status"
  fi

  read -r -p "Broadcast $target on $network? [y/N] " answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    echo "aborted before $target" >&2
    exit 1
  fi

  forge script "$target" --rpc-url "$network" --account "$ACCOUNT_NAME" --sender "$signer" \
    --broadcast --verify --slow -vvv

  # the json is written before the transaction lands; make sure the recorded adapter exists
  if [ -n "${json_key:-}" ]; then
    recorded=$(jq -r ".$json_key" "deployments/$json_name.json")
    if [ "$(cast code "$recorded" --rpc-url "$network")" = "0x" ]; then
      echo "deployments/$json_name.json records $json_key=$recorded but it has no code on $network" >&2
      exit 1
    fi
    echo "$json_key on $network: $recorded"
  fi
done
