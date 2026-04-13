// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {WildFungibility} from "./WildFungibility.sol";

/// @title SCALE Codec for XCM v5 `WildFungibility`
/// @notice SCALE-compliant encoder/decoder for the `WildFungibility` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library WildFungibilityCodec {
    error InvalidWildFungibilityLength();
    error InvalidWildFungibility(uint8 fType);

    /// @notice Encodes a `WildFungibility` value into bytes.
    /// @param wildFungibility The `WildFungibility` value to encode.
    /// @return SCALE-encoded byte sequence representing the `WildFungibility`.
    function encode(
        WildFungibility wildFungibility
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(wildFungibility));
    }

    /// @notice Returns the number of bytes that a `WildFungibility` value would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `WildFungibility`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `WildFungibility`.
    /// @return The number of bytes that the `WildFungibility` value would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (!(offset < data.length)) {
            revert InvalidWildFungibilityLength();
        }
        return 1;
    }

    /// @notice Decodes a `WildFungibility` value from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `WildFungibility`.
    /// @return wildFungibility The decoded `WildFungibility` value.
    /// @return bytesRead The total number of bytes read from `data` to decode the `WildFungibility`.
    function decode(
        bytes memory data
    )
        internal
        pure
        returns (WildFungibility wildFungibility, uint256 bytesRead)
    {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `WildFungibility` value from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `WildFungibility`.
    /// @param offset The starting index in `data` from which to decode the `WildFungibility`.
    /// @return wildFungibility The decoded `WildFungibility` value.
    /// @return bytesRead The total number of bytes read from `data` to decode the `WildFungibility`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    )
        internal
        pure
        returns (WildFungibility wildFungibility, uint256 bytesRead)
    {
        if (!(offset < data.length)) {
            revert InvalidWildFungibilityLength();
        }
        uint8 fType = uint8(data[offset]);
        if (fType > uint8(type(WildFungibility).max)) {
            revert InvalidWildFungibility(fType);
        }
        wildFungibility = WildFungibility(fType);
        bytesRead = 1;
    }
}
