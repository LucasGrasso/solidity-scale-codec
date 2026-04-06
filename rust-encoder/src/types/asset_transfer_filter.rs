use staging_xcm::v5::{
    Asset, AssetFilter, AssetId, AssetTransferFilter, Assets, Fungibility, Location, WildAsset,
};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    let asset_id = AssetId(Location::parent());
    let definite = AssetFilter::Definite(Assets::from(vec![Asset {
        id: asset_id.clone(),
        fun: Fungibility::Fungible(1_200_000_000),
    }]));
    let wild = AssetFilter::Wild(WildAsset::AllCounted(2));

    vec![
        encode_example(
            "asset_transfer_filter_teleport",
            AssetTransferFilter::Teleport(definite.clone()),
        ),
        encode_example(
            "asset_transfer_filter_reserve_deposit",
            AssetTransferFilter::ReserveDeposit(wild.clone()),
        ),
        encode_example(
            "asset_transfer_filter_reserve_withdraw",
            AssetTransferFilter::ReserveWithdraw(definite),
        ),
    ]
}
