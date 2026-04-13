// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {Instruction} from "../Instruction/Instruction.sol";
import {InstructionCodec} from "../Instruction/InstructionCodec.sol";
import {Xcm} from "./Xcm.sol";

/// @title SCALE Codec for XCM v5 `Xcm`
/// @notice SCALE-compliant encoder/decoder for the `Xcm` type.
/// @dev Rust parity: `Xcm<Call>(Vec<Instruction<Call>>)`, encoded as Compact length followed by each encoded instruction.
library XcmCodec {
    error InvalidXcmLength();

    /// @notice Encodes an `Xcm` into SCALE bytes.
    /// @param xcm The `Xcm` value to encode.
    /// @return SCALE-encoded byte sequence representing `xcm`.
    function encode(Xcm memory xcm) internal pure returns (bytes memory) {
        bytes memory encoded = Compact.encode(xcm.instructions.length);
        for (uint256 i = 0; i < xcm.instructions.length; ++i) {
            encoded = abi.encodePacked(
                encoded,
                InstructionCodec.encode(xcm.instructions[i])
            );
        }
        return encoded;
    }

    /// @notice Returns the number of bytes that an `Xcm` occupies when SCALE-encoded.
    /// @param data The byte sequence containing encoded `Xcm`.
    /// @param offset The starting index in `data` from which to calculate size.
    /// @return The number of bytes occupied by encoded `Xcm`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (!(offset < data.length)) revert InvalidXcmLength();

        (uint256 count, uint256 prefixSize) = Compact.decodeAt(data, offset);
        uint256 pos = offset + prefixSize;

        for (uint256 i = 0; i < count; ++i) {
            pos += InstructionCodec.encodedSizeAt(data, pos);
        }

        return pos - offset;
    }

    /// @notice Decodes an `Xcm` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing encoded `Xcm`.
    /// @return xcm The decoded `Xcm` value.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (Xcm memory xcm, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `Xcm` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing encoded `Xcm`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return xcm The decoded `Xcm` value.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Xcm memory xcm, uint256 bytesRead) {
        if (!(offset < data.length)) revert InvalidXcmLength();

        (uint256 count, uint256 prefixSize) = Compact.decodeAt(data, offset);
        Instruction[] memory instructions = new Instruction[](count);
        uint256 pos = offset + prefixSize;

        for (uint256 i = 0; i < count; ++i) {
            uint256 read;
            (instructions[i], read) = InstructionCodec.decodeAt(data, pos);
            pos += read;
        }

        xcm = Xcm({instructions: instructions});
        bytesRead = pos - offset;
    }
}
