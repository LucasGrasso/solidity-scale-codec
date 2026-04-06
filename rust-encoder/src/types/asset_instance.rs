use staging_xcm::v5::AssetInstance;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("asset_instance_undefined", AssetInstance::Undefined),
        encode_example("asset_instance_index", AssetInstance::Index(7)),
        encode_example("asset_instance_array4", AssetInstance::Array4([1, 2, 3, 4])),
        encode_example("asset_instance_array8", AssetInstance::Array8([1; 8])),
        encode_example("asset_instance_array16", AssetInstance::Array16([2; 16])),
        encode_example("asset_instance_array32", AssetInstance::Array32([3; 32])),
    ]
}
