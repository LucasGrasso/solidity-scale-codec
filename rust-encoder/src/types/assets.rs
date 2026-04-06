use staging_xcm::v5::{Asset, AssetId, Assets, Fungibility, Location};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    let asset = Asset {
        id: AssetId(Location::parent()),
        fun: Fungibility::Fungible(1_200_000_000),
    };

    vec![encode_example("assets", Assets::from(vec![asset]))]
}
