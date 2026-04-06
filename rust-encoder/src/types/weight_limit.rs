use staging_xcm::v5::{Weight, WeightLimit};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("weight_limit_unlimited", WeightLimit::Unlimited),
        encode_example(
            "weight_limit_limited",
            WeightLimit::Limited(Weight::from_parts(12, 34)),
        ),
    ]
}
