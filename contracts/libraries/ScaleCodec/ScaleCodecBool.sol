// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../LittleEndian/LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder for `bool`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodecBool {
    /// @notice Encodes a boolean into SCALE format (1-byte little-endian).
    /// @param self The boolean to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bool self) internal pure returns (bytes memory) {
        uint8 x = self ? uint8(1) : uint8(0);
        bytes1 b = LittleEndian.toLittleEndianU8(x);
        return abi.encodePacked(b);
    }
}
