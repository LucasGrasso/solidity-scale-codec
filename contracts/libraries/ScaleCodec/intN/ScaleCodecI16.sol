// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `int16`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecI16 {
    /// @notice Encodes a `int16` into SCALE format (2-byte twos-complement little-endian).
    /// @param self The signed 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int16 self) internal pure returns (bytes memory) {
        bytes2 b = LittleEndian.toLittleEndianI16(self);
        return abi.encodePacked(b);
    }
}
