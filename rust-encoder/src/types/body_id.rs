use staging_xcm::v5::BodyId;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("body_id_unit", BodyId::Unit),
        encode_example("body_id_moniker", BodyId::Moniker(*b"DOT!")),
        encode_example("body_id_index", BodyId::Index(42)),
        encode_example("body_id_executive", BodyId::Executive),
        encode_example("body_id_technical", BodyId::Technical),
        encode_example("body_id_legislative", BodyId::Legislative),
        encode_example("body_id_judicial", BodyId::Judicial),
        encode_example("body_id_defense", BodyId::Defense),
        encode_example("body_id_administration", BodyId::Administration),
        encode_example("body_id_treasury", BodyId::Treasury),
    ]
}
