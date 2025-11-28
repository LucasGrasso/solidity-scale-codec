// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import { I32 } from "../Signed.sol";

/// @title Scale Codec for the `int32[]` type.
/// @notice SCALE-compliant encoder/decoder for the `int32[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I32Arr {
	using I32 for int32;

	/// @notice Encodes an `int32[]` into SCALE format.
	function encode(int32[] memory arr) internal pure returns (bytes memory) {
		bytes memory result = Compact.encode(arr.length);
		for (uint256 i = 0; i < arr.length; i++) {
			result = bytes.concat(result, arr[i].encode());
		}
		return result;
	}

	/// @notice Decodes an `int32[]` from SCALE format.
	function decode(bytes memory data) 
		internal pure returns (int32[] memory arr, uint256 bytesRead) 
	{
		return decodeAt(data, 0);
	}

	/// @notice Decodes an `int32[]` from SCALE format.
	function decodeAt(bytes memory data, uint256 offset) 
		internal pure returns (int32[] memory arr, uint256 bytesRead) 
	{
		(uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
		uint256 pos = offset + compactBytes;
		
		arr = new int32[](length);
		for (uint256 i = 0; i < length; i++) {
			arr[i] = I32.decodeAt(data, pos);
			pos += 4;
		}
		
		bytesRead = pos - offset;
	}
}
