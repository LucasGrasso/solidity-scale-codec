// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

library BytesConverter {
    error InvalidLength();

    function toBytes1(bytes memory data) internal pure returns (bytes1 result) {
        if (data.length < 1) revert InvalidLength();
        assembly {
            result := mload(add(data, 32))
        }
    }

    function toBytes2(bytes memory data) internal pure returns (bytes2 result) {
        if (data.length < 2) revert InvalidLength();
        assembly {
            result := mload(add(data, 32))
        }
    }

    function toBytes4(bytes memory data) internal pure returns (bytes4 result) {
        if (data.length < 4) revert InvalidLength();
        assembly {
            result := mload(add(data, 32))
        }
    }

    function toBytes8(bytes memory data) internal pure returns (bytes8 result) {
        if (data.length < 8) revert InvalidLength();
        assembly {
            result := mload(add(data, 32))
        }
    }

    function toBytes16(
        bytes memory data
    ) internal pure returns (bytes16 result) {
        if (data.length < 16) revert InvalidLength();
        assembly {
            result := mload(add(data, 32))
        }
    }

    function toBytes32(
        bytes memory data
    ) internal pure returns (bytes32 result) {
        if (data.length < 32) revert InvalidLength();
        assembly {
            result := mload(add(data, 32))
        }
    }
}
