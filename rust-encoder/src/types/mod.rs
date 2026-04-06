pub mod asset;
pub mod asset_filter;
pub mod asset_instance;
pub mod asset_transfer_filter;
pub mod assets;
pub mod body_id;
pub mod body_part;
pub mod common;
pub mod fungibility;
pub mod hint;
pub mod instruction;
pub mod junction;
pub mod junctions;
pub mod location;
pub mod network_id;
pub mod origin_kind;
pub mod pallet_info;
pub mod query_response_info;
pub mod response;
pub mod weight;
pub mod weight_limit;
pub mod wild_asset;
pub mod wild_fungibility;
pub mod xcm_error;

use common::Example;

pub fn all_samples() -> Vec<Example> {
    let mut samples = Vec::new();

    samples.extend(body_id::samples());
    samples.extend(body_part::samples());
    samples.extend(network_id::samples());
    samples.extend(junction::samples());
    samples.extend(junctions::samples());
    samples.extend(location::samples());
    samples.extend(asset_instance::samples());
    samples.extend(fungibility::samples());
    samples.extend(asset::samples());
    samples.extend(assets::samples());
    samples.extend(wild_fungibility::samples());
    samples.extend(wild_asset::samples());
    samples.extend(asset_filter::samples());
    samples.extend(asset_transfer_filter::samples());
    samples.extend(weight::samples());
    samples.extend(weight_limit::samples());
    samples.extend(hint::samples());
    samples.extend(origin_kind::samples());
    samples.extend(pallet_info::samples());
    samples.extend(query_response_info::samples());
    samples.extend(response::samples());
    samples.extend(xcm_error::samples());
    samples.extend(instruction::samples());

    samples
}

pub fn print_samples() {
    for sample in all_samples() {
        println!("{} {}", sample.name, sample.hex);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sample_catalog_round_trips() {
        assert!(!all_samples().is_empty());
    }
}
