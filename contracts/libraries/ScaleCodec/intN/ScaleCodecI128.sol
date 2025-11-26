// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `int128`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecI128 {
    /// @notice Encodes a `int128` into SCALE format (16-byte twos-complement little-endian).
    /// @param self The signed 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int128 self) internal pure returns (bytes memory) {
        bytes16 b = LittleEndian.toLittleEndianI128(self);
        return abi.encodePacked(b);
    }
}
