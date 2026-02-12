import {
arbitrum,
optimism,
zksync, 
linea,
sonic,
mantle,
ink,
soneium,
bob,
celo,
gnosis,
metis,
plasma,
xLayer,
megaeth,
mainnet,
avalanche,
bsc,
scroll,
polygon, 
base
} from 'viem/chains';
import {z} from 'zod';

export const CHAIN_ID = {
  MAINNET: mainnet.id,
  OPTIMISM: optimism.id,
  POLYGON: polygon.id,
  ARBITRUM: arbitrum.id,
  AVALANCHE: avalanche.id,
  METIS: metis.id,
  BASE: base.id,
  SCROLL: scroll.id,
  BNB: bsc.id,
  GNOSIS: gnosis.id,
  CELO: celo.id,
  LINEA: linea.id,
  SONIC: sonic.id,
  MANTLE: mantle.id,
  INK: ink.id,
  SONEIUM: soneium.id,
  BOB: bob.id,
  PLASMA: plasma.id,
  XLAYER: xLayer.id,
  MEGAETH: megaeth.id,
  ZKSYNC: zksync.id,
} as const;

const zodChainId = z.nativeEnum(CHAIN_ID);

export type CHAIN_ID = z.infer<typeof zodChainId>;

export const aDIReceiverConfigSchema = z.object({
  requiredConfirmations: z.string(),
  validityTimestamp: z.string(),
});
export const aDIAdapterSchema = z.record(z.string(), z.string());

export const optimalBandwidthSchema = z.object({
  optimalBandwidth: z.string(),
});

export const aDISnapshotSchema = z.object({
  receiverConfigs: z.record(z.string(), aDIReceiverConfigSchema),
  forwarderAdaptersByChain: z.record(z.string(), z.union([aDIAdapterSchema, z.string()])),
  receiverAdaptersByChain: z.record(z.string(), aDIAdapterSchema),
  optimalBandwidthByChain: z.record(z.string(), optimalBandwidthSchema),
  crossChainControllerImpl: z.string(),
  chainId: z.number(),
});

export type ADISnapshot = z.infer<typeof aDISnapshotSchema>;



