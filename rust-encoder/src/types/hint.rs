use staging_xcm::v5::{Hint, Location};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![encode_example(
        "hint_asset_claimer",
        Hint::AssetClaimer {
            location: Location::parent(),
        },
    )]
}
