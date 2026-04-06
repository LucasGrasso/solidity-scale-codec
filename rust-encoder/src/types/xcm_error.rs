use staging_xcm::v5::Error as XcmError;

use super::common::{encode_example, Example};

pub fn samples() -> Vec<Example> {
    vec![
        encode_example("xcm_error_overflow", XcmError::Overflow),
        encode_example("xcm_error_unimplemented", XcmError::Unimplemented),
        encode_example(
            "xcm_error_untrusted_reserve_location",
            XcmError::UntrustedReserveLocation,
        ),
        encode_example(
            "xcm_error_untrusted_teleport_location",
            XcmError::UntrustedTeleportLocation,
        ),
        encode_example("xcm_error_location_full", XcmError::LocationFull),
        encode_example(
            "xcm_error_location_not_invertible",
            XcmError::LocationNotInvertible,
        ),
        encode_example("xcm_error_bad_origin", XcmError::BadOrigin),
        encode_example("xcm_error_invalid_location", XcmError::InvalidLocation),
        encode_example("xcm_error_asset_not_found", XcmError::AssetNotFound),
        encode_example(
            "xcm_error_failed_to_transact_asset",
            XcmError::FailedToTransactAsset(""),
        ),
        encode_example("xcm_error_not_withdrawable", XcmError::NotWithdrawable),
        encode_example(
            "xcm_error_location_cannot_hold",
            XcmError::LocationCannotHold,
        ),
        encode_example(
            "xcm_error_exceeds_max_message_size",
            XcmError::ExceedsMaxMessageSize,
        ),
        encode_example(
            "xcm_error_destination_unsupported",
            XcmError::DestinationUnsupported,
        ),
        encode_example("xcm_error_transport", XcmError::Transport("")),
        encode_example("xcm_error_unroutable", XcmError::Unroutable),
        encode_example("xcm_error_unknown_claim", XcmError::UnknownClaim),
        encode_example("xcm_error_failed_to_decode", XcmError::FailedToDecode),
        encode_example("xcm_error_max_weight_invalid", XcmError::MaxWeightInvalid),
        encode_example("xcm_error_not_holding_fees", XcmError::NotHoldingFees),
        encode_example("xcm_error_too_expensive", XcmError::TooExpensive),
        encode_example("xcm_error_trap", XcmError::Trap(9)),
        encode_example("xcm_error_expectation_false", XcmError::ExpectationFalse),
        encode_example("xcm_error_pallet_not_found", XcmError::PalletNotFound),
        encode_example("xcm_error_name_mismatch", XcmError::NameMismatch),
        encode_example(
            "xcm_error_version_incompatible",
            XcmError::VersionIncompatible,
        ),
        encode_example(
            "xcm_error_holding_would_overflow",
            XcmError::HoldingWouldOverflow,
        ),
        encode_example("xcm_error_export_error", XcmError::ExportError),
        encode_example("xcm_error_reanchor_failed", XcmError::ReanchorFailed),
        encode_example("xcm_error_no_deal", XcmError::NoDeal),
        encode_example("xcm_error_fees_not_met", XcmError::FeesNotMet),
        encode_example("xcm_error_lock_error", XcmError::LockError),
        encode_example("xcm_error_no_permission", XcmError::NoPermission),
        encode_example("xcm_error_unanchored", XcmError::Unanchored),
        encode_example("xcm_error_not_depositable", XcmError::NotDepositable),
    ]
}
