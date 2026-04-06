use staging_xcm::v5::PalletInfo;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![encode_example(
        "pallet_info_balances",
        PalletInfo::new(
            10,
            b"balances".to_vec(),
            b"pallet_balances".to_vec(),
            1,
            2,
            3,
        )
        .expect("valid pallet info"),
    )]
}
