// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Assets} from "../Assets/Assets.sol";
import {AssetsCodec} from "../Assets/AssetsCodec.sol";
import {XcmError} from "../XcmError/XcmError.sol";
import {XcmErrorCodec} from "../XcmError/XcmErrorCodec.sol";
import {PalletInfo} from "../PalletInfo/PalletInfo.sol";
import {PalletInfoCodec} from "../PalletInfo/PalletInfoCodec.sol";
import {MaybeErrorCode} from "../../v3/MaybeErrorCode/MaybeErrorCode.sol";
import {MaybeErrorCodeCodec} from "../../v3/MaybeErrorCode/MaybeErrorCodeCodec.sol";
import {Compact} from "../../../Scale/Compact.sol";
import {LittleEndianU32} from "../../../LittleEndian/LittleEndianU32.sol";
import {Response, ResponseType} from "./Response.sol";

/// @title SCALE Codec for XCM v5 `Response`
/// @notice SCALE-compliant encoder/decoder for the `Response` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library ResponseCodec {
    error InvalidResponseLength();
    error InvalidResponseType(uint8 rType);

    /// @notice Encodes a `Response` struct into SCALE bytes.
    /// @param r The `Response` struct to encode.
    /// @return SCALE-encoded bytes representing the `Response`.
    function encode(Response memory r) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(r.rType), r.payload);
    }

    /// @notice Returns the number of bytes that a `Response` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `Response`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `Response`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidResponseLength();
        uint8 rType = uint8(data[offset]);
        uint256 pos = offset + 1;

        if (rType == uint8(ResponseType.Null)) {
            return 1;
        } else if (rType == uint8(ResponseType.Assets)) {
            return 1 + AssetsCodec.encodedSizeAt(data, pos);
        } else if (rType == uint8(ResponseType.ExecutionResult)) {
            if (data.length < pos + 1) revert InvalidResponseLength();
            uint8 isSome = uint8(data[pos]);
            if (isSome == 0) return 2; // 1 type + 1 None byte
            return 2 + 4 + XcmErrorCodec.encodedSizeAt(data, pos + 1 + 4);
        } else if (rType == uint8(ResponseType.Version)) {
            return 1 + 4; // 1 type + 4 bytes for version
        } else if (rType == uint8(ResponseType.PalletsInfo)) {
            (uint256 count, uint256 prefixSize) = Compact.decodeAt(data, pos);
            uint256 size = prefixSize;
            uint256 innerPos = pos + prefixSize;
            for (uint256 i = 0; i < count; ++i) {
                uint256 palletSize = PalletInfoCodec.encodedSizeAt(
                    data,
                    innerPos
                );
                size += palletSize;
                innerPos += palletSize;
            }
            return 1 + size;
        } else if (rType == uint8(ResponseType.DispatchResult)) {
            return 1 + MaybeErrorCodeCodec.encodedSizeAt(data, pos);
        } else {
            revert InvalidResponseType(rType);
        }
    }

    /// @notice Decodes a `Response` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `Response`.
    /// @return r The decoded `Response` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (Response memory r, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `Response` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `Response`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return r The decoded `Response` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Response memory r, uint256 bytesRead) {
        if (data.length < offset + 1) revert InvalidResponseLength();
        uint8 rType = uint8(data[offset]);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; ++i) {
            payload[i] = data[offset + 1 + i];
        }
        r = Response({rType: ResponseType(rType), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the `Assets` from an `Assets` response.
    /// @param r The `Response` struct. Must be of type `Assets`.
    /// @return The decoded `Assets`.
    function asAssets(Response memory r) internal pure returns (Assets memory) {
        if (r.rType != ResponseType.Assets)
            revert InvalidResponseType(uint8(r.rType));
        (Assets memory a, ) = AssetsCodec.decode(r.payload);
        return a;
    }

    /// @notice Decodes the execution result from an `ExecutionResult` response.
    /// @param r The `Response` struct. Must be of type `ExecutionResult`.
    /// @return hasError Whether the execution result contains an error.
    /// @return index The instruction index that caused the error. Only meaningful if `hasError` is true.
    /// @return err The XCM error. Only meaningful if `hasError` is true.
    function asExecutionResult(
        Response memory r
    ) internal pure returns (bool hasError, uint32 index, XcmError memory err) {
        if (r.rType != ResponseType.ExecutionResult)
            revert InvalidResponseType(uint8(r.rType));
        hasError = r.payload[0] != 0;
        if (hasError) {
            index = LittleEndianU32.fromLittleEndian(r.payload, 1);
            (err, ) = XcmErrorCodec.decodeAt(r.payload, 1 + 4);
        }
    }

    /// @notice Decodes the version from a `Version` response.
    /// @param r The `Response` struct. Must be of type `Version`.
    /// @return The decoded version.
    function asVersion(Response memory r) internal pure returns (uint32) {
        if (r.rType != ResponseType.Version)
            revert InvalidResponseType(uint8(r.rType));
        return LittleEndianU32.fromLittleEndian(r.payload, 0);
    }

    /// @notice Decodes the pallets info from a `PalletsInfo` response.
    /// @param r The `Response` struct. Must be of type `PalletsInfo`.
    /// @return pallets The decoded array of `PalletInfo`.
    function asPalletsInfo(
        Response memory r
    ) internal pure returns (PalletInfo[] memory pallets) {
        if (r.rType != ResponseType.PalletsInfo)
            revert InvalidResponseType(uint8(r.rType));
        (uint256 count, uint256 prefixSize) = Compact.decodeAt(r.payload, 0);
        pallets = new PalletInfo[](count);
        uint256 pos = prefixSize;
        for (uint256 i = 0; i < count; ++i) {
            uint256 read;
            (pallets[i], read) = PalletInfoCodec.decodeAt(r.payload, pos);
            pos += read;
        }
    }

    /// @notice Decodes the dispatch result from a `DispatchResult` response.
    /// @param r The `Response` struct. Must be of type `DispatchResult`.
    /// @return The decoded `MaybeErrorCode`.
    function asDispatchResult(
        Response memory r
    ) internal pure returns (MaybeErrorCode memory) {
        if (r.rType != ResponseType.DispatchResult)
            revert InvalidResponseType(uint8(r.rType));
        (MaybeErrorCode memory me, ) = MaybeErrorCodeCodec.decode(r.payload);
        return me;
    }
}
