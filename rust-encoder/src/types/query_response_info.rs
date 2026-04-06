use staging_xcm::v5::{Location, QueryResponseInfo, Weight};

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![encode_example(
        "query_response_info",
        QueryResponseInfo {
            destination: Location::parent(),
            query_id: 7,
            max_weight: Weight::from_parts(5, 11),
        },
    )]
}
