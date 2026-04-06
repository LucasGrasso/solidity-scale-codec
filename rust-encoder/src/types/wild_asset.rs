use staging_xcm::v5::{AssetId, Location, WildAsset, WildFungibility};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    let asset_id = AssetId(Location::parent());

    vec![
        encode_example("wild_asset_all", WildAsset::All),
        encode_example(
            "wild_asset_all_of",
            WildAsset::AllOf {
                id: asset_id.clone(),
                fun: WildFungibility::Fungible,
            },
        ),
        encode_example("wild_asset_all_counted", WildAsset::AllCounted(2)),
        encode_example(
            "wild_asset_all_of_counted",
            WildAsset::AllOfCounted {
                id: asset_id,
                fun: WildFungibility::NonFungible,
                count: 3,
            },
        ),
    ]
}
