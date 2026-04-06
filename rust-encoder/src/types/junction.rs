use staging_xcm::v5::{BodyId, BodyPart, Junction, NetworkId};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("junction_parachain", Junction::Parachain(1000)),
        encode_example(
            "junction_account_id32",
            Junction::AccountId32 {
                network: Some(NetworkId::Polkadot),
                id: [0x33; 32],
            },
        ),
        encode_example(
            "junction_account_index64",
            Junction::AccountIndex64 {
                network: Some(NetworkId::Kusama),
                index: 123_456,
            },
        ),
        encode_example(
            "junction_account_key20",
            Junction::AccountKey20 {
                network: None,
                key: [0x44; 20],
            },
        ),
        encode_example("junction_pallet_instance", Junction::PalletInstance(7)),
        encode_example(
            "junction_general_index",
            Junction::GeneralIndex(123_456_789),
        ),
        encode_example(
            "junction_general_key",
            Junction::GeneralKey {
                length: 4,
                data: [
                    1, 2, 3, 4, 0xAA, 0xBB, 0xCC, 0xDD, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
                    0x88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                ],
            },
        ),
        encode_example("junction_only_child", Junction::OnlyChild),
        encode_example(
            "junction_plurality",
            Junction::Plurality {
                id: BodyId::Executive,
                part: BodyPart::Voice,
            },
        ),
        encode_example(
            "junction_global_consensus",
            Junction::GlobalConsensus(NetworkId::Polkadot),
        ),
    ]
}
