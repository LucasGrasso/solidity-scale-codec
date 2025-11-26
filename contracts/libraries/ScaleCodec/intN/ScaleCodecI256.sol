// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `int256`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecI256 {
    /// @notice Encodes a `int256` into SCALE format (32-byte twos-complement little-endian).
    /// @param self The signed 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int256 self) internal pure returns (bytes memory) {
        bytes32 b = LittleEndian.toLittleEndianI256(self);
        return abi.encodePacked(b);
    }
}
