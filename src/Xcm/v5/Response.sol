// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetsCodec, Assets} from "./Assets.sol";
import {XcmErrorCodec, XcmError} from "./XcmError.sol";
import {PalletInfoCodec, PalletInfo} from "./PalletInfo.sol";
import {MaybeErrorCodeCodec, MaybeErrorCode} from "../v3/MaybeErrorCode.sol";
import {Version} from "../Types/Version.sol";
import {Compact} from "../../Scale/Compact.sol";
import {LittleEndianU32} from "../../LittleEndian/LittleEndianU32.sol";
import {MAX_PALLETS_INFO} from "./Constants.sol";

/// @notice Discriminant for the `Response` enum.
enum ResponseType {
    /// @custom:variant No response. Serves as a neutral default.
    Null,
    /// @custom:variant Some assets.
    Assets,
    /// @custom:variant The outcome of an XCM instruction.
    ExecutionResult,
    /// @custom:variant An XCM version.
    Version,
    /// @custom:variant The index, instance name, pallet name and version of some pallets.
    PalletsInfo,
    /// @custom:variant The status of a dispatch attempt using `Transact`.
    DispatchResult
}

/// @notice Response data to a query.
struct Response {
    /// @custom:property The type of the response. See `ResponseType` enum for possible values.
    ResponseType rType;
    /// @custom:property The SCALE-encoded payload of the response. Structure depends on `rType`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `Response`
/// @notice SCALE-compliant encoder/decoder for the `Response` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library ResponseCodec {
    error InvalidResponseLength();
    error InvalidResponseType(uint8 rType);

    using LittleEndianU32 for uint32;

    /// @notice Creates a `Null` response.
    /// @return A `Response` struct representing the null response.
    function null_() internal pure returns (Response memory) {
        return Response({rType: ResponseType.Null, payload: ""});
    }

    /// @notice Creates an `Assets` response.
    /// @param assets_ The assets to include in the response.
    /// @return A `Response` struct representing the assets response.
    function assets(
        Assets memory assets_
    ) internal pure returns (Response memory) {
        return
            Response({
                rType: ResponseType.Assets,
                payload: AssetsCodec.encode(assets_)
            });
    }

    /// @notice Creates an `ExecutionResult` response with no error.
    /// @return A `Response` struct representing a successful execution result.
    function executionResultSuccess() internal pure returns (Response memory) {
        // Option<(u32, Error)>: None = 0x00
        return
            Response({
                rType: ResponseType.ExecutionResult,
                payload: abi.encodePacked(uint8(0))
            });
    }

    /// @notice Creates an `ExecutionResult` response with an error.
    /// @param index The index of the instruction that caused the error.
    /// @param err The XCM error that occurred.
    /// @return A `Response` struct representing a failed execution result.
    function executionResultError(
        uint32 index,
        XcmError memory err
    ) internal pure returns (Response memory) {
        return
            Response({
                rType: ResponseType.ExecutionResult,
                payload: abi.encodePacked(
                    uint8(1),
                    index.toLittleEndian(),
                    XcmErrorCodec.encode(err)
                )
            });
    }

    /// @notice Creates a `Version` response.
    /// @param version_ The XCM version.
    /// @return A `Response` struct representing the version response.
    function version(uint32 version_) internal pure returns (Response memory) {
        return
            Response({
                rType: ResponseType.Version,
                payload: abi.encodePacked(version_.toLittleEndian())
            });
    }

    /// @notice Creates a `PalletsInfo` response.
    /// @param pallets The pallet info array. Max length is MAX_PALLETS_INFO (64).
    /// @return A `Response` struct representing the pallets info response.
    function palletsInfo(
        PalletInfo[] memory pallets
    ) internal pure returns (Response memory) {
        bytes memory encoded = Compact.encode(pallets.length);
        for (uint256 i = 0; i < pallets.length; ++i) {
            encoded = bytes.concat(encoded, PalletInfoCodec.encode(pallets[i]));
        }
        return Response({rType: ResponseType.PalletsInfo, payload: encoded});
    }

    /// @notice Creates a `DispatchResult` response.
    /// @param result The `MaybeErrorCode` dispatch result.
    /// @return A `Response` struct representing the dispatch result response.
    function dispatchResult(
        MaybeErrorCode memory result
    ) internal pure returns (Response memory) {
        return
            Response({
                rType: ResponseType.DispatchResult,
                payload: MaybeErrorCodeCodec.encode(result)
            });
    }

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
    function decodeAssets(
        Response memory r
    ) internal pure returns (Assets memory) {
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
    function decodeExecutionResult(
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
    function decodeVersion(Response memory r) internal pure returns (uint32) {
        if (r.rType != ResponseType.Version)
            revert InvalidResponseType(uint8(r.rType));
        return LittleEndianU32.fromLittleEndian(r.payload, 0);
    }

    /// @notice Decodes the pallets info from a `PalletsInfo` response.
    /// @param r The `Response` struct. Must be of type `PalletsInfo`.
    /// @return pallets The decoded array of `PalletInfo`.
    function decodePalletsInfo(
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
    function decodeDispatchResult(
        Response memory r
    ) internal pure returns (MaybeErrorCode memory) {
        if (r.rType != ResponseType.DispatchResult)
            revert InvalidResponseType(uint8(r.rType));
        (MaybeErrorCode memory me, ) = MaybeErrorCodeCodec.decode(r.payload);
        return me;
    }
}
