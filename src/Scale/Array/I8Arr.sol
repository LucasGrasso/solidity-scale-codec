// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import { I8 } from "../Signed.sol";

/// @title Scale Codec for the `int8[]` type.
/// @notice SCALE-compliant encoder/decoder for the `int8[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I8Arr {
	using I8 for int8;

	/// @notice Encodes an `int8[]` into SCALE format.
	function encode(int8[] memory arr) internal pure returns (bytes memory) {
		bytes memory result = Compact.encode(arr.length);
		for (uint256 i = 0; i < arr.length; i++) {
			result = bytes.concat(result, arr[i].encode());
		}
		return result;
	}

	/// @notice Decodes an `int8[]` from SCALE format.
	function decode(bytes memory data) 
		internal pure returns (int8[] memory arr, uint256 bytesRead) 
	{
		return decodeAt(data, 0);
	}

	/// @notice Decodes an `int8[]` from SCALE format.
	function decodeAt(bytes memory data, uint256 offset) 
		internal pure returns (int8[] memory arr, uint256 bytesRead) 
	{
		(uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
		uint256 pos = offset + compactBytes;
		
		arr = new int8[](length);
		for (uint256 i = 0; i < length; i++) {
			arr[i] = I8.decodeAt(data, pos);
			pos += 1;
		}
		
		bytesRead = pos - offset;
	}
}
