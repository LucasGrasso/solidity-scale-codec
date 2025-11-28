// SPDX-License-Identifier: Apache-2.0
// AUTO-GENERATED - DO NOT EDIT
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import {ScaleCodec} from "./ScaleCodec.sol";

/// @title Scale Codec for solidity arrays.
/// @notice SCALE-compliant encoder/decoder for solidity arrays.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library ScaleCodecArrays {
    // ============ `uint8[]` ============

    /// @notice Encodes an `uint8[]` into SCALE format.
    function encodeU8Array(
        uint8[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeU8(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `uint8[]` from SCALE format.
    function decodeU8Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint8[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new uint8[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeU8At(data, pos);
            pos += 1;
        }

        bytesRead = pos - offset;
    }

    // ============ `uint16[]` ============

    /// @notice Encodes an `uint16[]` into SCALE format.
    function encodeU16Array(
        uint16[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeU16(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `uint16[]` from SCALE format.
    function decodeU16Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint16[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new uint16[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeU16At(data, pos);
            pos += 2;
        }

        bytesRead = pos - offset;
    }

    // ============ `uint32[]` ============

    /// @notice Encodes an `uint32[]` into SCALE format.
    function encodeU32Array(
        uint32[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeU32(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `uint32[]` from SCALE format.
    function decodeU32Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint32[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new uint32[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeU32At(data, pos);
            pos += 4;
        }

        bytesRead = pos - offset;
    }

    // ============ `uint64[]` ============

    /// @notice Encodes an `uint64[]` into SCALE format.
    function encodeU64Array(
        uint64[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeU64(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `uint64[]` from SCALE format.
    function decodeU64Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint64[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new uint64[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeU64At(data, pos);
            pos += 8;
        }

        bytesRead = pos - offset;
    }

    // ============ `uint128[]` ============

    /// @notice Encodes an `uint128[]` into SCALE format.
    function encodeU128Array(
        uint128[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeU128(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `uint128[]` from SCALE format.
    function decodeU128Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint128[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeU128At(data, pos);
            pos += 16;
        }

        bytesRead = pos - offset;
    }

    // ============ `uint256[]` ============

    /// @notice Encodes an `uint256[]` into SCALE format.
    function encodeU256Array(
        uint256[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeU256(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `uint256[]` from SCALE format.
    function decodeU256Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeU256At(data, pos);
            pos += 32;
        }

        bytesRead = pos - offset;
    }

    // ============ `int8[]` ============

    /// @notice Encodes an `int8[]` into SCALE format.
    function encodeI8Array(
        int8[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeI8(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `int8[]` from SCALE format.
    function decodeI8Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int8[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new int8[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeI8At(data, pos);
            pos += 1;
        }

        bytesRead = pos - offset;
    }

    // ============ `int16[]` ============

    /// @notice Encodes an `int16[]` into SCALE format.
    function encodeI16Array(
        int16[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeI16(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `int16[]` from SCALE format.
    function decodeI16Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int16[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new int16[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeI16At(data, pos);
            pos += 2;
        }

        bytesRead = pos - offset;
    }

    // ============ `int32[]` ============

    /// @notice Encodes an `int32[]` into SCALE format.
    function encodeI32Array(
        int32[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeI32(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `int32[]` from SCALE format.
    function decodeI32Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int32[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new int32[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeI32At(data, pos);
            pos += 4;
        }

        bytesRead = pos - offset;
    }

    // ============ `int64[]` ============

    /// @notice Encodes an `int64[]` into SCALE format.
    function encodeI64Array(
        int64[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeI64(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `int64[]` from SCALE format.
    function decodeI64Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int64[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new int64[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeI64At(data, pos);
            pos += 8;
        }

        bytesRead = pos - offset;
    }

    // ============ `int128[]` ============

    /// @notice Encodes an `int128[]` into SCALE format.
    function encodeI128Array(
        int128[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeI128(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `int128[]` from SCALE format.
    function decodeI128Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int128[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new int128[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeI128At(data, pos);
            pos += 16;
        }

        bytesRead = pos - offset;
    }

    // ============ `int256[]` ============

    /// @notice Encodes an `int256[]` into SCALE format.
    function encodeI256Array(
        int256[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeI256(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `int256[]` from SCALE format.
    function decodeI256Array(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int256[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new int256[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeI256At(data, pos);
            pos += 32;
        }

        bytesRead = pos - offset;
    }

    // ============ `bool[]` ============

    /// @notice Encodes an `bool[]` into SCALE format.
    function encodeBoolArray(
        bool[] memory arr
    ) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result = bytes.concat(result, ScaleCodec.encodeBool(arr[i]));
        }
        return result;
    }

    /// @notice Decodes an `bool[]` from SCALE format.
    function decodeBoolArray(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bool[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        arr = new bool[](length);
        for (uint256 i = 0; i < length; i++) {
            arr[i] = ScaleCodec.decodeBoolAt(data, pos);
            pos += 1;
        }

        bytesRead = pos - offset;
    }
}
