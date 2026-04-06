use staging_xcm::v5::{AssetInstance, Fungibility};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("fungibility_fungible", Fungibility::Fungible(1_200_000_000)),
        encode_example(
            "fungibility_non_fungible",
            Fungibility::NonFungible(AssetInstance::Array4([9, 8, 7, 6])),
        ),
    ]
}
