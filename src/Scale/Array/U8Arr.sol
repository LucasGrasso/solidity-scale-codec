// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import { U8 } from "../Unsigned.sol";

/// @title Scale Codec for the `uint8[]` type.
/// @notice SCALE-compliant encoder/decoder for the `uint8[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U8Arr {
	using U8 for uint8;

	/// @notice Encodes an `uint8[]` into SCALE format.
	function encode(uint8[] memory arr) internal pure returns (bytes memory) {
		bytes memory result = Compact.encode(arr.length);
		for (uint256 i = 0; i < arr.length; i++) {
			result = bytes.concat(result, arr[i].encode());
		}
		return result;
	}

	/// @notice Decodes an `uint8[]` from SCALE format.
	function decode(bytes memory data) 
		internal pure returns (uint8[] memory arr, uint256 bytesRead) 
	{
		return decodeAt(data, 0);
	}

	/// @notice Decodes an `uint8[]` from SCALE format.
	function decodeAt(bytes memory data, uint256 offset) 
		internal pure returns (uint8[] memory arr, uint256 bytesRead) 
	{
		(uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
		uint256 pos = offset + compactBytes;
		
		arr = new uint8[](length);
		for (uint256 i = 0; i < length; i++) {
			arr[i] = U8.decodeAt(data, pos);
			pos += 1;
		}
		
		bytesRead = pos - offset;
	}
}
