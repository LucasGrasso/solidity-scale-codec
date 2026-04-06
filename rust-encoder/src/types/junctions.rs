use staging_xcm::v5::{Junction, Junctions, NetworkId};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("junctions_here", Junctions::Here),
        encode_example("junctions_x1", Junctions::from([Junction::Parachain(1000)])),
        encode_example(
            "junctions_x2",
            Junctions::from([Junction::Parachain(1000), Junction::OnlyChild]),
        ),
        encode_example(
            "junctions_x3",
            Junctions::from([
                Junction::Parachain(1000),
                Junction::OnlyChild,
                Junction::GeneralIndex(7),
            ]),
        ),
        encode_example(
            "junctions_x4",
            Junctions::from([
                Junction::Parachain(1000),
                Junction::OnlyChild,
                Junction::GeneralIndex(7),
                Junction::GlobalConsensus(NetworkId::Polkadot),
            ]),
        ),
        encode_example(
            "junctions_x5",
            Junctions::from([
                Junction::Parachain(1000),
                Junction::OnlyChild,
                Junction::GeneralIndex(7),
                Junction::GlobalConsensus(NetworkId::Polkadot),
                Junction::PalletInstance(1),
            ]),
        ),
        encode_example(
            "junctions_x6",
            Junctions::from([
                Junction::Parachain(1000),
                Junction::OnlyChild,
                Junction::GeneralIndex(7),
                Junction::GlobalConsensus(NetworkId::Polkadot),
                Junction::PalletInstance(1),
                Junction::OnlyChild,
            ]),
        ),
        encode_example(
            "junctions_x7",
            Junctions::from([
                Junction::Parachain(1000),
                Junction::OnlyChild,
                Junction::GeneralIndex(7),
                Junction::GlobalConsensus(NetworkId::Polkadot),
                Junction::PalletInstance(1),
                Junction::OnlyChild,
                Junction::Parachain(2000),
            ]),
        ),
        encode_example(
            "junctions_x8",
            Junctions::from([
                Junction::Parachain(1000),
                Junction::OnlyChild,
                Junction::GeneralIndex(7),
                Junction::GlobalConsensus(NetworkId::Polkadot),
                Junction::PalletInstance(1),
                Junction::OnlyChild,
                Junction::Parachain(2000),
                Junction::GeneralKey {
                    length: 2,
                    data: [
                        0x55, 0x66, 0xAA, 0xBB, 0xCC, 0xDD, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66,
                        0x77, 0x88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    ],
                },
            ]),
        ),
    ]
}
