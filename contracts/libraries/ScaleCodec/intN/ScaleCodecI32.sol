// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `int32`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecI32 {
    /// @notice Encodes a `int32` into SCALE format (4-byte twos-complement little-endian).
    /// @param self The signed 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int32 self) internal pure returns (bytes memory) {
        bytes4 b = LittleEndian.toLittleEndianI32(self);
        return abi.encodePacked(b);
    }
}
