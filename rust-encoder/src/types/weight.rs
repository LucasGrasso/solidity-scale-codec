use staging_xcm::v5::Weight;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("weight_zero", Weight::from_parts(0, 0)),
        encode_example("weight_small", Weight::from_parts(12, 34)),
        encode_example("weight_large", Weight::from_parts(1_000_000, 2_000_000)),
    ]
}
