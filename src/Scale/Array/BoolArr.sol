// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import { Bool } from "../Bool.sol";

/// @title Scale Codec for the `bool[]` type.
/// @notice SCALE-compliant encoder/decoder for the `bool[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library BoolArr {
	using Bool for bool;

	/// @notice Encodes an `bool[]` into SCALE format.
	function encode(bool[] memory arr) internal pure returns (bytes memory) {
		bytes memory result = Compact.encode(arr.length);
		for (uint256 i = 0; i < arr.length; i++) {
			result = bytes.concat(result, arr[i].encode());
		}
		return result;
	}

	/// @notice Decodes an `bool[]` from SCALE format.
	function decode(bytes memory data) 
		internal pure returns (bool[] memory arr, uint256 bytesRead) 
	{
		return decodeAt(data, 0);
	}

	/// @notice Decodes an `bool[]` from SCALE format.
	function decodeAt(bytes memory data, uint256 offset) 
		internal pure returns (bool[] memory arr, uint256 bytesRead) 
	{
		(uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
		uint256 pos = offset + compactBytes;
		
		arr = new bool[](length);
		for (uint256 i = 0; i < length; i++) {
			arr[i] = Bool.decodeAt(data, pos);
			pos += 1;
		}
		
		bytesRead = pos - offset;
	}
}
