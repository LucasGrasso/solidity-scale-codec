use staging_xcm::v5::NetworkId;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("network_id_by_genesis", NetworkId::ByGenesis([0x11; 32])),
        encode_example(
            "network_id_by_fork",
            NetworkId::ByFork {
                block_number: 42,
                block_hash: [0x22; 32],
            },
        ),
        encode_example("network_id_polkadot", NetworkId::Polkadot),
        encode_example("network_id_kusama", NetworkId::Kusama),
        encode_example("network_id_ethereum", NetworkId::Ethereum { chain_id: 1 }),
        encode_example("network_id_bitcoin_core", NetworkId::BitcoinCore),
        encode_example("network_id_bitcoin_cash", NetworkId::BitcoinCash),
        encode_example("network_id_polkadot_bulletin", NetworkId::PolkadotBulletin),
    ]
}
