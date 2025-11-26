// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `uint64`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecU64 {
    /// @notice Encodes a `uint64` into SCALE format (8-byte little-endian).
    /// @param self The unsigned 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint64 self) internal pure returns (bytes memory) {
        bytes8 b = LittleEndian.toLittleEndianU64(self);
        return abi.encodePacked(b);
    }
}
