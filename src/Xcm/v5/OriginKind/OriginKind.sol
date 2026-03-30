// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @notice Basically just the XCM (more general) version of ParachainDispatchOrigin.
enum OriginKind {
    /// @custom:variant Origin should just be the native dispatch origin representation for the sender in the local runtime framework. For Cumulus/Frame chains this is the Parachain or Relay origin if coming from a chain, though there may be others if the MultiLocation XCM origin has a primary/native dispatch origin form.
    Native,
    /// @custom:variant Origin should just be the standard account-based origin with the sovereign account of the sender. For Cumulus/Frame chains, this is the Signed origin.
    SovereignAccount,
    /// @custom:variant Origin should be the super-user. For Cumulus/Frame chains, this is the Root origin. This will not usually be an available option.
    Superuser,
    /// @custom:variant Origin should be interpreted as an XCM native origin and the MultiLocation should be encoded directly in the dispatch origin unchanged. For Cumulus/Frame chains, this will be the `pallet_xcm::Origin::Xcm` type.
    Xcm
}
