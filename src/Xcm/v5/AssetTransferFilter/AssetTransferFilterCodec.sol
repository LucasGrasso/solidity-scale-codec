// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetFilterCodec} from "../AssetFilter/AssetFilterCodec.sol";
import {AssetTransferFilter, AssetTransferFilterVariant, TeleportParams, ReserveDepositParams, ReserveWithdrawParams} from "./AssetTransferFilter.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";

/// @title SCALE Codec for XCM v5 `AssetTransferFilter`
/// @notice SCALE-compliant encoder/decoder for the `AssetTransferFilter` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/enum.AssetTransferFilter.html
library AssetTransferFilterCodec {
    error InvalidAssetTransferFilterLength();
    error InvalidAssetTransferFilterVariant(uint8 variant);

    /// @notice Encodes an `AssetTransferFilter` struct into SCALE bytes.
    /// @param atf The `AssetTransferFilter` struct to encode.
    /// @return SCALE-encoded bytes representing the `AssetTransferFilter`.
    function encode(
        AssetTransferFilter memory atf
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(atf.variant), atf.payload);
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
        uint8 variant = uint8(data[offset]);
        if (variant > uint8(AssetTransferFilterVariant.ReserveWithdraw))
            revert InvalidAssetTransferFilterVariant(variant);
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
        uint256 size = encodedSizeAt(data, offset);
        uint8 variant = uint8(data[offset]);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        atf = AssetTransferFilter({
            variant: AssetTransferFilterVariant(variant),
            payload: payload
        });
        bytesRead = size;
    }

    /// @notice Extracts the inner `AssetFilter` from an `AssetTransferFilter` with `Teleport` variant
    /// @param atf The `AssetTransferFilter` struct to decode.
    /// @return params A `TeleportParams` struct containing the inner `AssetFilter`.
    function asTeleport(
        AssetTransferFilter memory atf
    ) internal pure returns (TeleportParams memory params) {
        _assertVariant(atf, AssetTransferFilterVariant.Teleport);
        (params.assetFilter, ) = AssetFilterCodec.decode(atf.payload);
    }

    /// @notice Extracts the inner `AssetFilter` from an `AssetTransferFilter` with `ReserveDeposit` variant
    /// @param atf The `AssetTransferFilter` struct to decode.
    /// @return params A `ReserveDepositParams` struct containing the inner `AssetFilter`.
    function asReserveDeposit(
        AssetTransferFilter memory atf
    ) internal pure returns (ReserveDepositParams memory params) {
        _assertVariant(atf, AssetTransferFilterVariant.ReserveDeposit);
        (params.assetFilter, ) = AssetFilterCodec.decode(atf.payload);
    }

    /// @notice Extracts the inner `AssetFilter` from an `AssetTransferFilter` with `ReserveWithdraw` variant
    /// @param atf The `AssetTransferFilter` struct to decode.
    /// @return params A `ReserveWithdrawParams` struct containing the inner `AssetFilter`.
    function asReserveWithdraw(
        AssetTransferFilter memory atf
    ) internal pure returns (ReserveWithdrawParams memory params) {
        _assertVariant(atf, AssetTransferFilterVariant.ReserveWithdraw);
        (params.assetFilter, ) = AssetFilterCodec.decode(atf.payload);
    }

    function _assertVariant(
        AssetTransferFilter memory atf,
        AssetTransferFilterVariant expected
    ) private pure {
        if (atf.variant != expected) {
            revert InvalidAssetTransferFilterVariant(uint8(atf.variant));
        }
    }
}
