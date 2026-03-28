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

/// @title SCALE Codec for XCM v5 `BodyPart`
/// @notice SCALE-compliant encoder/decoder for the `BodyPart` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library OriginKindCodec {
    error InvalidOriginKind(uint8 originKind);

    /// @notice Encodes an `OriginKind` enum value into a bytes array using SCALE encoding.
    /// @param originKind The `OriginKind` value to encode.
    /// @return A bytes array containing the SCALE-encoded `OriginKind`.
    function encode(
        OriginKind originKind
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(originKind));
    }

    /// @notice Decodes a bytes array into an `OriginKind` enum value using SCALE decoding.
    /// @param data The bytes array containing the SCALE-encoded `OriginKind`.
    /// @return The decoded `OriginKind` value.
    function decode(bytes memory data) internal pure returns (OriginKind) {
        decodeAt(data, 0);
    }

    /// @notice Decodes a bytes array into an `OriginKind` enum value starting at a specific offset.
    /// @param data The bytes array containing the SCALE-encoded `OriginKind`.
    /// @param offset The byte offset in the data array to start decoding from.
    /// @return originKind The decoded `OriginKind` value.
    /// @return bytesRead The number of bytes read from the data array during decoding.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (OriginKind originKind, uint256 bytesRead) {
        if (offset >= data.length) {
            revert InvalidOriginKind(0);
        }
        uint8 originKindValue = uint8(data[offset]);
        if (originKindValue > uint8(OriginKind.Xcm)) {
            revert InvalidOriginKind(originKindValue);
        }
        originKind = OriginKind(originKindValue);
        bytesRead = 1;
    }
}
