// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {U8Arr} from "../Arr/U8Arr.sol";

/// @title Scale Codec for the `address` type.
/// @notice SCALE-compliant encoder/decoder for the `address` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Address {
    error InvalidAddressArrLenght();

    /// @notice Encodes an `address` into SCALE format (20-byte little-endian).
    /// @param value The `address` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(address value) internal pure returns (bytes memory) {
        uint8[] memory addrArr = _addressToUint8Array(value);
        return U8Arr.encode(addrArr);
    }

    /// @notice Decodes SCALE-encoded bytes into an `address`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return addr The decoded `address`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decode(
        bytes memory data
    ) internal pure returns (address addr, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `address` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return addr The decoded `address`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (address addr, uint256 bytesRead) {
        (uint8[] memory addrArr, uint256 bytesRead) = U8Arr.decodeAt(
            data,
            offset
        );

        if (addrArr.length != 20) revert InvalidAddressArrLenght();

        address result = _uint8ArrayToAddress(addrArr);
        return (result, bytesRead);
    }

    function _addressToUint8Array(
        address _addr
    ) private pure returns (uint8[] memory) {
        uint8[] memory result = new uint8[](20);
        uint160 addrValue = uint160(_addr);

        for (uint256 i = 0; i < 20; i++) {
            // Shift right to get the byte, then mask it
            result[i] = uint8(addrValue >> (8 * (19 - i)));
        }
        return result;
    }

    function _uint8ArrayToAddress(
        uint8[] memory arr
    ) private pure returns (address) {
        uint160 result = 0;
        for (uint256 i = 0; i < 20; i++) {
            result |= uint160(arr[i]) << (8 * (19 - i));
        }
        return address(result);
    }
}
