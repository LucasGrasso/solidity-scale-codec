use staging_xcm::v5::{
    Asset, AssetFilter, AssetId, Assets, Fungibility, Location, WildAsset, WildFungibility,
};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    let asset_id = AssetId(Location::parent());
    let assets = Assets::from(vec![Asset {
        id: asset_id.clone(),
        fun: Fungibility::Fungible(1_200_000_000),
    }]);
    let wild = WildAsset::AllOf {
        id: asset_id,
        fun: WildFungibility::Fungible,
    };

    vec![
        encode_example("asset_filter_definite", AssetFilter::Definite(assets)),
        encode_example("asset_filter_wild", AssetFilter::Wild(wild)),
    ]
}
