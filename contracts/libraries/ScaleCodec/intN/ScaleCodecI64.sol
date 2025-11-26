// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `int64`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecI64 {
    /// @notice Encodes a `int64` into SCALE format (8-byte twos-complement little-endian).
    /// @param self The signed 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int64 self) internal pure returns (bytes memory) {
        bytes8 b = LittleEndian.toLittleEndianI64(self);
        return abi.encodePacked(b);
    }
}
