use staging_xcm::v5::{Junction, Junctions, Location, NetworkId};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("location_here", Location::here()),
        encode_example("location_parent", Location::parent()),
        encode_example(
            "location_nested",
            Location::new(
                2,
                Junctions::from([
                    Junction::Parachain(1000),
                    Junction::AccountId32 {
                        network: Some(NetworkId::Polkadot),
                        id: [0x33; 32],
                    },
                ]),
            ),
        ),
    ]
}
