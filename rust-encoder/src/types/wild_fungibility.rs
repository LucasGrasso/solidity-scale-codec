use staging_xcm::v5::WildFungibility;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("wild_fungibility_fungible", WildFungibility::Fungible),
        encode_example("wild_fungibility_non_fungible", WildFungibility::NonFungible),
    ]
}
