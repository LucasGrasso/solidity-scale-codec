// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../Scale/Compact.sol";
import {Bytes4} from "../../Scale/Bytes/Bytes4.sol";
import {Bytes8} from "../../Scale/Bytes/Bytes8.sol";
import {Bytes16} from "../../Scale/Bytes/Bytes16.sol";
import {Bytes32} from "../../Scale/Bytes/Bytes32.sol";

/// @dev Discriminant for the different types of AssetInstances in XCM v5.
enum AssetInstanceType {
    /// @custom:variant Used if the non-fungible asset class has only one instance.
    Undefined,
    /// @custom:variant A compact index up to 2^128 - 1.
    Index,
    /// @custom:variant A 4-byte fixed-length datum.
    Array4,
    /// @custom:variant An 8-byte fixed-length datum.
    Array8,
    /// @custom:variant A 16-byte fixed-length datum.
    Array16,
    /// @custom:variant A 32-byte fixed-length datum.
    Array32
}

/// @notice A general identifier for an instance of a non-fungible asset class.
struct AssetInstance {
    /// @custom:property The type of asset instance, determining how to interpret the payload. See `AssetInstanceType` enum for possible values.
    AssetInstanceType iType;
    /// @custom:property The encoded payload containing the asset instance data, whose structure depends on the `iType`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `AssetInstance`
/// @notice SCALE-compliant encoder/decoder for the `AssetInstance` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library AssetInstanceCodec {
    error InvalidAssetInstanceLength();
    error InvalidAssetInstanceType(uint8 iType);
    error InvalidAssetInstancePayload();

    using Bytes4 for bytes4;
    using Bytes8 for bytes8;
    using Bytes16 for bytes16;
    using Bytes32 for bytes32;

    /// @notice Creates an `Undefined` asset instance.
    /// @return An `AssetInstance` struct with type `Undefined` and an empty payload.
    function undefined() internal pure returns (AssetInstance memory) {
        return
            AssetInstance({
                iType: AssetInstanceType.Undefined,
                payload: new bytes(0)
            });
    }

    /// @notice Creates an `Index` asset instance with the given index value.
    /// @param idx The index value for the asset instance, which must be less than 2^128.
    /// @return An `AssetInstance` struct with type `Index` and the provided index value encoded in the payload.
    function index(uint128 idx) internal pure returns (AssetInstance memory) {
        bytes memory payload = Compact.encode(idx);
        return
            AssetInstance({iType: AssetInstanceType.Index, payload: payload});
    }

    /// @notice Creates an `Array4` asset instance with the given 4-byte data.
    /// @param data The 4-byte data for the asset instance.
    /// @return An `AssetInstance` struct with type `Array4` and the provided data encoded in the payload.
    function array4(bytes4 data) internal pure returns (AssetInstance memory) {
        return
            AssetInstance({
                iType: AssetInstanceType.Array4,
                payload: data.encode()
            });
    }

    /// @notice Creates an `Array8` asset instance with the given 8-byte data.
    /// @param data The 8-byte data for the asset instance.
    /// @return An `AssetInstance` struct with type `Array8` and the provided data encoded in the payload.
    function array8(bytes8 data) internal pure returns (AssetInstance memory) {
        return
            AssetInstance({
                iType: AssetInstanceType.Array8,
                payload: data.encode()
            });
    }

    /// @notice Creates an `Array16` asset instance with the given 16-byte data.
    /// @param data The 16-byte data for the asset instance.
    /// @return An `AssetInstance` struct with type `Array16` and the provided data encoded in the payload.
    function array16(
        bytes16 data
    ) internal pure returns (AssetInstance memory) {
        return
            AssetInstance({
                iType: AssetInstanceType.Array16,
                payload: data.encode()
            });
    }

    /// @notice Creates an `Array32` asset instance with the given 32-byte data.
    /// @param data The 32-byte data for the asset instance.
    /// @return An `AssetInstance` struct with type `Array32` and the provided data encoded in the payload.
    function array32(
        bytes32 data
    ) internal pure returns (AssetInstance memory) {
        return
            AssetInstance({
                iType: AssetInstanceType.Array32,
                payload: data.encode()
            });
    }

    /// @notice Encodes an `AssetInstance` struct into bytes.
    /// @param assetInstance The `AssetInstance` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `AssetInstance`.
    function encode(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(assetInstance.iType, assetInstance.payload);
    }

    /// @notice Decodes an `AssetInstance` struct from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `AssetInstance`.
    /// @return assetInstance The decoded `AssetInstance` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `AssetInstance`.
    function decode(
        bytes memory data
    )
        internal
        pure
        returns (AssetInstance memory assetInstance, uint256 bytesRead)
    {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `AssetInstance` struct from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `AssetInstance`.
    /// @param offset The starting index in `data` from which to decode the `AssetInstance`.
    /// @return assetInstance The decoded `AssetInstance` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `AssetInstance`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    )
        internal
        pure
        returns (AssetInstance memory assetInstance, uint256 bytesRead)
    {
        if (data.length < offset + 1) {
            revert InvalidAssetInstanceLength();
        }
        uint8 iType = uint8(data[offset]);
        uint256 payloadLength;
        if (iType == uint8(AssetInstanceType.Index)) {
            payloadLength = 16; // u128 is 16 bytes
        } else if (iType == uint8(AssetInstanceType.Array4)) {
            payloadLength = 4;
        } else if (iType == uint8(AssetInstanceType.Array8)) {
            payloadLength = 8;
        } else if (iType == uint8(AssetInstanceType.Array16)) {
            payloadLength = 16;
        } else if (iType == uint8(AssetInstanceType.Array32)) {
            payloadLength = 32;
        } else if (iType == uint8(AssetInstanceType.Undefined)) {
            payloadLength = 0;
        } else {
            revert InvalidAssetInstanceType(iType);
        }

        if (data.length < offset + 1 + payloadLength) {
            revert InvalidAssetInstanceLength();
        }

        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; i++) {
            payload[i] = data[offset + 1 + i];
        }

        assetInstance = AssetInstance({
            iType: AssetInstanceType(iType),
            payload: payload
        });
        bytesRead = 1 + payloadLength;
    }

    /// @notice Decodes an `Index` asset instance, returning the index value.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Index`.
    /// @return idx The index value extracted from the asset instance.
    function decodeIndex(
        AssetInstance memory assetInstance
    ) internal pure returns (uint128 idx) {
        if (assetInstance.iType != AssetInstanceType.Index) {
            revert InvalidAssetInstanceType(uint8(assetInstance.iType));
        }
        (uint256 decodedIndex, ) = Compact.decode(assetInstance.payload);
        if (decodedIndex > type(uint128).max) {
            revert InvalidAssetInstancePayload();
        }
        unchecked {
            idx = uint128(decodedIndex);
        }
    }

    /// @notice Decodes an `Array4` asset instance, returning the 4-byte data.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array4`.
    /// @return data The 4-byte data extracted from the asset instance.
    function decodeArray4(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes4 data) {
        if (assetInstance.iType != AssetInstanceType.Array4) {
            revert InvalidAssetInstanceType(uint8(assetInstance.iType));
        }
        return Bytes4.decode(assetInstance.payload);
    }

    /// @notice Decodes an `Array8` asset instance, returning the 8-byte data.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array8`.
    /// @return data The 8-byte data extracted from the asset instance.
    function decodeArray8(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes8 data) {
        if (assetInstance.iType != AssetInstanceType.Array8) {
            revert InvalidAssetInstanceType(uint8(assetInstance.iType));
        }
        return Bytes8.decode(assetInstance.payload);
    }

    /// @notice Decodes an `Array16` asset instance, returning the 16-byte data.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array16`.
    /// @return data The 16-byte data extracted from the asset instance.
    function decodeArray16(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes16 data) {
        if (assetInstance.iType != AssetInstanceType.Array16) {
            revert InvalidAssetInstanceType(uint8(assetInstance.iType));
        }
        return Bytes16.decode(assetInstance.payload);
    }

    /// @notice Decodes an `Array32` asset instance, returning the 32-byte data.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array32`.
    /// @return data The 32-byte data extracted from the asset instance.
    function decodeArray32(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes32 data) {
        if (assetInstance.iType != AssetInstanceType.Array32) {
            revert InvalidAssetInstanceType(uint8(assetInstance.iType));
        }
        return Bytes32.decode(assetInstance.payload);
    }

    /// @notice Calculates the total number of bytes that an `AssetInstance` would occupy when encoded, based on the type and payload.
    /// @param data The byte sequence containing the encoded `AssetInstance`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The total number of bytes that the `AssetInstance` occupies in its encoded form, including the type byte and payload.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) {
            revert InvalidAssetInstanceLength();
        }
        uint8 iType = uint8(data[offset]);
        uint256 payloadLength;
        if (iType == uint8(AssetInstanceType.Index)) {
            payloadLength = 16; // u128 is 16 bytes
        } else if (iType == uint8(AssetInstanceType.Array4)) {
            payloadLength = 4;
        } else if (iType == uint8(AssetInstanceType.Array8)) {
            payloadLength = 8;
        } else if (iType == uint8(AssetInstanceType.Array16)) {
            payloadLength = 16;
        } else if (iType == uint8(AssetInstanceType.Array32)) {
            payloadLength = 32;
        } else if (iType == uint8(AssetInstanceType.Undefined)) {
            payloadLength = 0;
        } else {
            revert InvalidAssetInstanceType(iType);
        }

        return 1 + payloadLength;
    }
}
