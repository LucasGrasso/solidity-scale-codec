// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { U256 } from "../Unsigned/U256.sol";

/// @title Scale Codec for the `int256` type.
/// @notice SCALE-compliant encoder/decoder for the `int256` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I256 {
	/// @notice Encodes an `int256` into SCALE format (32-byte two's-complement little-endian).
    /// @param value The signed 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int256 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an `int256`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int256`.
    function decode(bytes memory data) internal pure returns (int256) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int256` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int256`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int256 value) {
        return int256(U256.decodeAt(data, offset));
    }

	/// @notice Converts an int256 to little-endian bytes32 (two's complement)
    function toLittleEndian(int256 value) internal pure returns (bytes32 result) {
        return U256.toLittleEndian(uint256(value));
    }
}