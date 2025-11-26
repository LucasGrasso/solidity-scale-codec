// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `uint8`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecU8 {
    /// @notice Encodes a `uint8` into SCALE format (1-byte little-endian).
    /// @param self The unsigned 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint8 self) internal pure returns (bytes memory) {
        bytes1 b = LittleEndian.toLittleEndianU8(self);
        return abi.encodePacked(b);
    }
}
