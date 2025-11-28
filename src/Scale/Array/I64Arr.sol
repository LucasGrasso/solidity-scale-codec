// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import { I64 } from "../Signed.sol";

/// @title Scale Codec for the `int64[]` type.
/// @notice SCALE-compliant encoder/decoder for the `int64[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I64Arr {
	using I64 for int64;

	/// @notice Encodes an `int64[]` into SCALE format.
	function encode(int64[] memory arr) internal pure returns (bytes memory) {
		bytes memory result = Compact.encode(arr.length);
		for (uint256 i = 0; i < arr.length; i++) {
			result = bytes.concat(result, arr[i].encode());
		}
		return result;
	}

	/// @notice Decodes an `int64[]` from SCALE format.
	function decode(bytes memory data) 
		internal pure returns (int64[] memory arr, uint256 bytesRead) 
	{
		return decodeAt(data, 0);
	}

	/// @notice Decodes an `int64[]` from SCALE format.
	function decodeAt(bytes memory data, uint256 offset) 
		internal pure returns (int64[] memory arr, uint256 bytesRead) 
	{
		(uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
		uint256 pos = offset + compactBytes;
		
		arr = new int64[](length);
		for (uint256 i = 0; i < length; i++) {
			arr[i] = I64.decodeAt(data, pos);
			pos += 8;
		}
		
		bytesRead = pos - offset;
	}
}
