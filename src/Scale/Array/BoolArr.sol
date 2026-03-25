// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../Compact/Compact.sol";
import { Bool } from "../Bool.sol";

/// @title Scale Codec for the `bool[]` type.
/// @notice SCALE-compliant encoder/decoder for the `bool[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library BoolArr {
	error InvalidBoolArrLenght();

	using Bool for bool;

	/// @notice Encodes an `bool[]` into SCALE format.
	/// @param arr The array of `bool` to encode.
	/// @return SCALE-encoded byte sequence.
	function encode(bool[] memory arr) internal pure returns (bytes memory) {
		bytes memory result = Compact.encode(arr.length);
		for (uint256 i = 0; i < arr.length; ++i) {
			result = bytes.concat(result, arr[i].encode());
		}
		return result;
	}

	/// @notice Decodes an `bool[]` from SCALE format.
	/// @param data The SCALE-encoded byte sequence.
	/// @return arr The decoded array of `bool`.
	/// @return bytesRead The total number of bytes read during decoding.
	function decode(bytes memory data) 
		internal pure returns (bool[] memory arr, uint256 bytesRead) 
	{
		return decodeAt(data, 0);
	}

	/// @notice Decodes an `bool[]` from SCALE format at the specified offset.
	/// @param data The SCALE-encoded byte sequence.
	/// @param offset The byte offset to start decoding from.
	/// @return arr The decoded array of `bool`.
	/// @return bytesRead The total number of bytes read during decoding.
	function decodeAt(bytes memory data, uint256 offset) 
		internal pure returns (bool[] memory arr, uint256 bytesRead) 
	{
		(uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
		uint256 pos = offset + compactBytes;

		if (pos + (length * 1) > data.length) revert InvalidBoolArrLenght();
		
		arr = new bool[](length);
		for (uint256 i = 0; i < length; ++i) {
			arr[i] = Bool.decodeAt(data, pos);
			pos += 1;
		}
		
		bytesRead = pos - offset;
	}
}
