use staging_xcm::v5::{Asset, AssetId, AssetInstance, Fungibility, Location};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    let parent_location = Location::parent();
    let asset_id = AssetId(parent_location);

    vec![
        encode_example(
            "asset_fungible",
            Asset {
                id: asset_id.clone(),
                fun: Fungibility::Fungible(1_200_000_000),
            },
        ),
        encode_example(
            "asset_non_fungible",
            Asset {
                id: asset_id,
                fun: Fungibility::NonFungible(AssetInstance::Array32([0x44; 32])),
            },
        ),
    ]
}
