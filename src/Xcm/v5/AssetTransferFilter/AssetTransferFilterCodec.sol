// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetFilter} from "../AssetFilter/AssetFilter.sol";
import {AssetFilterCodec} from "../AssetFilter/AssetFilterCodec.sol";
import {
    AssetTransferFilter,
    AssetTransferFilterType
} from "./AssetTransferFilter.sol";

/// @title SCALE Codec for XCM v5 `AssetTransferFilter`
/// @notice SCALE-compliant encoder/decoder for the `AssetTransferFilter` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/enum.AssetTransferFilter.html
library AssetTransferFilterCodec {
    error InvalidAssetTransferFilterLength();
    error InvalidAssetTransferFilterType(uint8 atfType);

    /// @notice Encodes an `AssetTransferFilter` struct into SCALE bytes.
    /// @param atf The `AssetTransferFilter` struct to encode.
    /// @return SCALE-encoded bytes representing the `AssetTransferFilter`.
    function encode(
        AssetTransferFilter memory atf
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(atf.atfType), atf.payload);
    }

    /// @notice Returns the number of bytes that an `AssetTransferFilter` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `AssetTransferFilter`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `AssetTransferFilter`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidAssetTransferFilterLength();
        uint8 atfType = uint8(data[offset]);
        if (atfType > uint8(AssetTransferFilterType.ReserveWithdraw))
            revert InvalidAssetTransferFilterType(atfType);
        return 1 + AssetFilterCodec.encodedSizeAt(data, offset + 1);
    }

    /// @notice Decodes an `AssetTransferFilter` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `AssetTransferFilter`.
    /// @return atf The decoded `AssetTransferFilter` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    )
        internal
        pure
        returns (AssetTransferFilter memory atf, uint256 bytesRead)
    {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `AssetTransferFilter` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `AssetTransferFilter`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return atf The decoded `AssetTransferFilter` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    )
        internal
        pure
        returns (AssetTransferFilter memory atf, uint256 bytesRead)
    {
        if (data.length < offset + 1) revert InvalidAssetTransferFilterLength();
        uint8 atfType = uint8(data[offset]);
        if (atfType > uint8(AssetTransferFilterType.ReserveWithdraw))
            revert InvalidAssetTransferFilterType(atfType);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; ++i) {
            payload[i] = data[offset + 1 + i];
        }
        atf = AssetTransferFilter({
            atfType: AssetTransferFilterType(atfType),
            payload: payload
        });
        bytesRead = size;
    }

    /// @notice Extracts the inner `AssetFilter` from an `AssetTransferFilter`.
    /// @param atf The `AssetTransferFilter` struct to decode.
    /// @return The inner `AssetFilter`.
    function asInner(
        AssetTransferFilter memory atf
    ) internal pure returns (AssetFilter memory) {
        return AssetFilterCodec.decode(atf.payload);
    }
}
