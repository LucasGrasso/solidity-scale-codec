use staging_xcm::v5::BodyPart;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("body_part_voice", BodyPart::Voice),
        encode_example("body_part_members", BodyPart::Members { count: 7 }),
        encode_example(
            "body_part_fraction",
            BodyPart::Fraction { nom: 2, denom: 3 },
        ),
        encode_example(
            "body_part_at_least_proportion",
            BodyPart::AtLeastProportion { nom: 1, denom: 2 },
        ),
        encode_example(
            "body_part_more_than_proportion",
            BodyPart::MoreThanProportion { nom: 2, denom: 3 },
        ),
    ]
}
