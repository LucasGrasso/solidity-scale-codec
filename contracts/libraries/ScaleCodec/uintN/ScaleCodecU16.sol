// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `uint16`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecU16 {
    /// @notice Encodes a `uint16` into SCALE format (2-byte little-endian).
    /// @param self The unsigned 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint16 self) internal pure returns (bytes memory) {
        bytes2 b = LittleEndian.toLittleEndianU16(self);
        return abi.encodePacked(b);
    }
}
