// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `int8`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecI8 {
    /// @notice Encodes a `int8` into SCALE format (1-byte twos-complement little-endian).
    /// @param self The signed 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int8 self) internal pure returns (bytes memory) {
        bytes1 b = LittleEndian.toLittleEndianI8(self);
        return abi.encodePacked(b);
    }
}
