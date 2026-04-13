// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {Bytes} from "../../../Scale/Bytes.sol";
import {MAX_PALLET_NAME_LEN} from "../Constants.sol";
import {PalletInfo} from "./PalletInfo.sol";

/// @title SCALE Codec for XCM v5 `PalletInfo`
/// @notice SCALE-compliant encoder/decoder for the `PalletInfo` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library PalletInfoCodec {
    error InvalidPalletInfoLength();
    error PalletNameTooLong(uint256 length);

    /// @notice Encodes a `PalletInfo` struct into SCALE bytes.
    /// @param info The `PalletInfo` struct to encode.
    /// @return SCALE-encoded bytes representing the `PalletInfo`.
    function encode(
        PalletInfo memory info
    ) internal pure returns (bytes memory) {
        if (info.name.length > MAX_PALLET_NAME_LEN)
            revert PalletNameTooLong(info.name.length);
        if (info.moduleName.length > MAX_PALLET_NAME_LEN)
            revert PalletNameTooLong(info.moduleName.length);
        return
            abi.encodePacked(
                Compact.encode(info.index),
                Bytes.encode(info.name),
                Bytes.encode(info.moduleName),
                Compact.encode(info.major),
                Compact.encode(info.minor),
                Compact.encode(info.patch)
            );
    }

    /// @notice Returns the number of bytes that a `PalletInfo` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `PalletInfo`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `PalletInfo`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidPalletInfoLength();
        uint256 pos = offset;
        pos += Compact.encodedSizeAt(data, pos); // index
        pos += Bytes.encodedSizeAt(data, pos); // name
        pos += Bytes.encodedSizeAt(data, pos); // moduleName
        pos += Compact.encodedSizeAt(data, pos); // major
        pos += Compact.encodedSizeAt(data, pos); // minor
        pos += Compact.encodedSizeAt(data, pos); // patch
        return pos - offset;
    }

    /// @notice Decodes a `PalletInfo` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `PalletInfo`.
    /// @return info The decoded `PalletInfo` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (PalletInfo memory info, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `PalletInfo` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `PalletInfo`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return info The decoded `PalletInfo` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (PalletInfo memory info, uint256 bytesRead) {
        uint256 pos = offset;
        uint256 index;
        uint256 read;

        (index, read) = Compact.decodeAt(data, pos);
        pos += read;

        bytes memory name;
        (name, read) = Bytes.decodeAt(data, pos);
        pos += read;

        bytes memory moduleName;
        (moduleName, read) = Bytes.decodeAt(data, pos);
        pos += read;

        uint256 major;
        (major, read) = Compact.decodeAt(data, pos);
        pos += read;

        uint256 minor;
        (minor, read) = Compact.decodeAt(data, pos);
        pos += read;

        uint256 patch;
        (patch, read) = Compact.decodeAt(data, pos);
        pos += read;

        if (name.length > MAX_PALLET_NAME_LEN)
            revert PalletNameTooLong(name.length);

        if (moduleName.length > MAX_PALLET_NAME_LEN)
            revert PalletNameTooLong(moduleName.length);

        info = PalletInfo({
            index: uint32(index),
            name: name,
            moduleName: moduleName,
            major: uint32(major),
            minor: uint32(minor),
            patch: uint32(patch)
        });
        bytesRead = pos - offset;
    }
}
