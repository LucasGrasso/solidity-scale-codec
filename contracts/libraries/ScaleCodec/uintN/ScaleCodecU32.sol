// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `uint32`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecU32 {
    /// @notice Encodes a `uint32` into SCALE format (4-byte little-endian).
    /// @param self The unsigned 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint32 self) internal pure returns (bytes memory) {
        bytes4 b = LittleEndian.toLittleEndianU32(self);
        return abi.encodePacked(b);
    }
}
