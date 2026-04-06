use bounded_collections::BoundedVec;
use staging_xcm::v5::{
    Asset, AssetId, Assets, Error as XcmError, Fungibility, Location, MaxPalletsInfo,
    MaybeErrorCode, PalletInfo, Response,
};

use super::common::{encode_example, Example};

fn bounded_pallets(pallets: Vec<PalletInfo>) -> BoundedVec<PalletInfo, MaxPalletsInfo> {
    BoundedVec::try_from(pallets).expect("bounded pallet list")
}

pub fn samples() -> Vec<Example> {
    let assets = Assets::from(vec![Asset {
        id: AssetId(Location::parent()),
        fun: Fungibility::Fungible(1_200_000_000),
    }]);

    vec![
        encode_example("response_null", Response::Null),
        encode_example("response_assets", Response::Assets(assets)),
        encode_example(
            "response_execution_result_none",
            Response::ExecutionResult(None),
        ),
        encode_example(
            "response_execution_result_some",
            Response::ExecutionResult(Some((3, XcmError::Trap(7)))),
        ),
        encode_example("response_version", Response::Version(5)),
        encode_example(
            "response_pallets_info",
            Response::PalletsInfo(bounded_pallets(vec![PalletInfo::new(
                10,
                b"balances".to_vec(),
                b"pallet_balances".to_vec(),
                1,
                2,
                3,
            )
            .expect("valid pallet info")])),
        ),
        encode_example(
            "response_dispatch_result_success",
            Response::DispatchResult(MaybeErrorCode::Success),
        ),
        encode_example(
            "response_dispatch_result_error",
            Response::DispatchResult(MaybeErrorCode::from(vec![1, 2, 3])),
        ),
        encode_example(
            "response_dispatch_result_truncated",
            Response::DispatchResult(MaybeErrorCode::from(vec![0u8; 200])),
        ),
    ]
}
