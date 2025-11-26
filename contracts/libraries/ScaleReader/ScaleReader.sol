// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "../LittleEndian/LittleEndian.sol";

/**
 * @title SCALEReader
 * @notice A lightweight, cursor-based reader for decoding SCALE-encoded data.
 *
 * @dev This reader provides efficient sequential decoding without repeated calldata slicing.
 *      Decoding functions advance an internal offset, eliminating redundant bounds checks
 *      and reducing gas costs. The reader supports primitives (bool, uintN, intN).
 *
 * @dev Key properties:
 *      - The reader holds a reference to a byte buffer and a cursor (`offset`).
 *      - Every `readX` method advances the cursor by the required number of bytes.
 *      - A failing read reverts with `OutOfBounds(required, remaining)`.
 *      - All integers are read using little-endian order.
 *
 * @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
 */
library SCALEReader {
    /// @dev Thrown when attempting to read beyond the available data.
    error OutOfBounds(uint256 required, uint256 remaining);

    /// @notice Stateful cursor for sequential SCALE decoding.
    struct Reader {
        /// @custom:property holds the full SCALE-encoded buffer.
        bytes data;
        /// @custom:property `offset` is incremented by each read operation.
        uint256 offset;
    }

    /**
     * @notice Initializes a new SCALEReader from a byte array.
     * @param input SCALE-encoded byte sequence.
     * @return r A reader positioned at offset zero.
     */
    function fromBytes(
        bytes calldata input
    ) internal pure returns (Reader memory r) {
        r.data = input;
        r.offset = 0;
    }

    // --------------------------------------------------------------
    //  Internal utils
    // --------------------------------------------------------------

    /**
     * @notice Ensures that `needed` bytes can be read from the reader.
     * @param r The SCALE reader state.
     * @param needed Number of bytes required.
     *
     * @dev Reverts with `OutOfBounds` if not enough bytes remain.
     */
    function _ensure(Reader memory r, uint256 needed) private pure {
        uint256 remaining = r.data.length - r.offset;
        if (needed > remaining) {
            revert OutOfBounds(needed, remaining);
        }
    }

    /**
     * @notice Reads `n` bytes from the reader and returns them right-aligned in a bytes32.
     * @param r The SCALE reader state.
     * @param n Number of bytes to read.
     * @return out The raw bytes, located in the low-order portion of the returned bytes32.
     *
     * @dev Advances `r.offset` by `n`.
     * @dev Performs no endian conversion.
     */
    function _read(
        Reader memory r,
        uint256 n
    ) private pure returns (bytes32 out) {
        _ensure(r, n);

        assembly {
            // pointer to Reader struct
            let rptr := r

            // load bytes pointer
            let data := mload(rptr)

            // load offset
            let off := mload(add(rptr, 32))

            // pointer to actual bytes contents
            let dataPtr := add(data, 32)

            // load bytes32 at data+offset
            out := mload(add(dataPtr, off))
        }

        r.offset += n;
    }

    // --------------------------------------------------------------
    //  Fixed Width Primitives
    // --------------------------------------------------------------

    // -------- Booleans --------

    /**
     * @notice Reads a 1-byte boolean.
     * @param r The SCALE reader state.
     * @return Boolean value (`false` if zero; `true` otherwise).
     */
    function readBool(Reader memory r) internal pure returns (bool) {
        return LittleEndian.fromLittleEndianU8(bytes1(_read(r, 1))) != 0;
    }

    // -------- Unsigned Integers --------

    /**
     * @notice Reads a 1-byte unsigned integer.
     * @param r The SCALE reader state.
     * @return uint8 decoded from little-endian format.
     */
    function readU8(Reader memory r) internal pure returns (uint8) {
        return LittleEndian.fromLittleEndianU8(bytes1(_read(r, 1)));
    }

    /**
     * @notice Reads a 2-byte unsigned integer in little-endian format.
     * @param r The SCALE reader state.
     * @return uint16 decoded value.
     */
    function readU16(Reader memory r) internal pure returns (uint16) {
        return LittleEndian.fromLittleEndianU16(bytes2(_read(r, 2)));
    }

    /**
     * @notice Reads a 4-byte unsigned integer in little-endian format.
     * @param r The SCALE reader state.
     * @return uint32 decoded value.
     */
    function readU32(Reader memory r) internal pure returns (uint32) {
        return LittleEndian.fromLittleEndianU32(bytes4(_read(r, 4)));
    }

    /**
     * @notice Reads an 8-byte unsigned integer in little-endian format.
     * @param r The SCALE reader state.
     * @return uint64 decoded value.
     */
    function readU64(Reader memory r) internal pure returns (uint64) {
        return LittleEndian.fromLittleEndianU64(bytes8(_read(r, 8)));
    }

    /**
     * @notice Reads a 16-byte unsigned integer in little-endian format.
     * @param r The SCALE reader state.
     * @return uint128 decoded value.
     */
    function readU128(Reader memory r) internal pure returns (uint128) {
        return LittleEndian.fromLittleEndianU128(bytes16(_read(r, 16)));
    }

    /**
     * @notice Reads a 32-byte unsigned integer in little-endian format.
     * @param r The SCALE reader state.
     * @return uint256 decoded value.
     */
    function readU256(Reader memory r) internal pure returns (uint256) {
        return LittleEndian.fromLittleEndianU256(bytes32(_read(r, 32)));
    }

    // -------- Signed Integers --------

    /**
     * @notice Reads a 1-byte signed integer.
     * @param r The SCALE reader state.
     * @return uint8 decoded value.
     */
    function readI8(Reader memory r) internal pure returns (int8) {
        return LittleEndian.fromLittleEndianI8(bytes1(_read(r, 1)));
    }

    /**
     * @notice Reads a 2-byte signed integer in twos-complement little-endian format.
     * @param r The SCALE reader state.
     * @return uint16 decoded value.
     */
    function readI16(Reader memory r) internal pure returns (int16) {
        return LittleEndian.fromLittleEndianI16(bytes2(_read(r, 2)));
    }

    /**
     * @notice Reads a 4-byte signed integer in twos-complement little-endian format.
     * @param r The SCALE reader state.
     * @return uint32 decoded value.
     */
    function readI32(Reader memory r) internal pure returns (int32) {
        return LittleEndian.fromLittleEndianI32(bytes4(_read(r, 4)));
    }

    /**
     * @notice Reads an 8-byte signed integer in twos-complement little-endian format.
     * @param r The SCALE reader state.
     * @return uint64 decoded value.
     */
    function readI64(Reader memory r) internal pure returns (int64) {
        return LittleEndian.fromLittleEndianI64(bytes8(_read(r, 8)));
    }

    /**
     * @notice Reads a 16-byte signed integer in twos-complement little-endian format.
     * @param r The SCALE reader state.
     * @return uint128 decoded value.
     */
    function readI128(Reader memory r) internal pure returns (int128) {
        return LittleEndian.fromLittleEndianI128(bytes16(_read(r, 16)));
    }

    /**
     * @notice Reads a 32-byte signed integer in twos-complement little-endian format.
     * @param r The SCALE reader state.
     * @return uint256 decoded value.
     */
    function readI256(Reader memory r) internal pure returns (int256) {
        return LittleEndian.fromLittleEndianI256(bytes32(_read(r, 32)));
    }
}
