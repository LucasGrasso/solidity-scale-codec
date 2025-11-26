// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `uint128`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecU128 {
    /// @notice Encodes a `uint128` into SCALE format (16-byte little-endian).
    /// @param self The unsigned 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint128 self) internal pure returns (bytes memory) {
        bytes16 b = LittleEndian.toLittleEndianU128(self);
        return abi.encodePacked(b);
    }
}
