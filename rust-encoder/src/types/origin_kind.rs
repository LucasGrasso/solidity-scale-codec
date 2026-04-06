use staging_xcm::v5::OriginKind;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("origin_kind_native", OriginKind::Native),
        encode_example("origin_kind_sovereign_account", OriginKind::SovereignAccount),
        encode_example("origin_kind_superuser", OriginKind::Superuser),
        encode_example("origin_kind_xcm", OriginKind::Xcm),
    ]
}
