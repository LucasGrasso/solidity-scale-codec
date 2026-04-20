// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetsCodec} from "../Assets/AssetsCodec.sol";
import {XcmErrorCodec} from "../XcmError/XcmErrorCodec.sol";
import {PalletInfo} from "../PalletInfo/PalletInfo.sol";
import {PalletInfoCodec} from "../PalletInfo/PalletInfoCodec.sol";
import {MaybeErrorCodeCodec} from "../../v3/MaybeErrorCode/MaybeErrorCodeCodec.sol";
import {Compact} from "../../../Scale/Compact/Compact.sol";
import {LittleEndianU32} from "../../../LittleEndian/LittleEndianU32.sol";
import {
    Response,
    ResponseVariant,
    AssetsParams,
    VersionParams,
    DispatchResultParams,
    ExecutionResultParams,
    PalletsInfoParams
} from "./Response.sol";

import {BytesUtils} from "../../../Utils/BytesUtils.sol";

/// @title SCALE Codec for XCM v5 `Response`
/// @notice SCALE-compliant encoder/decoder for the `Response` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library ResponseCodec {
    error InvalidResponseLength();
    error InvalidResponseVariant(uint8 variant);

    /// @notice Encodes a `Response` struct into SCALE bytes.
    /// @param r The `Response` struct to encode.
    /// @return SCALE-encoded bytes representing the `Response`.
    function encode(Response memory r) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(r.variant), r.payload);
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
        uint8 variant = uint8(data[offset]);
        uint256 pos = offset + 1;

        if (variant == uint8(ResponseVariant.Null)) {
            return 1;
        } else if (variant == uint8(ResponseVariant.Assets)) {
            return 1 + AssetsCodec.encodedSizeAt(data, pos);
        } else if (variant == uint8(ResponseVariant.ExecutionResult)) {
            if (data.length < pos + 1) revert InvalidResponseLength();
            uint8 isSome = uint8(data[pos]);
            if (isSome == 0) return 2; // 1 type + 1 None byte
            return 2 + 4 + XcmErrorCodec.encodedSizeAt(data, pos + 1 + 4);
        } else if (variant == uint8(ResponseVariant.Version)) {
            if (data.length < pos + 4) revert InvalidResponseLength();
            return 1 + 4; // 1 type + 4 bytes for version
        } else if (variant == uint8(ResponseVariant.PalletsInfo)) {
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
        } else if (variant == uint8(ResponseVariant.DispatchResult)) {
            return 1 + MaybeErrorCodeCodec.encodedSizeAt(data, pos);
        } else {
            revert InvalidResponseVariant(variant);
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
        uint256 size = encodedSizeAt(data, offset);
        uint8 variant = uint8(data[offset]);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        r = Response({variant: ResponseVariant(variant), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the `Assets` from an `Assets` response.
    /// @param r The `Response` struct. Must be of type `Assets`.
    /// @return params An `AssetsParams` struct containing the decoded assets.
    function asAssets(
        Response memory r
    ) internal pure returns (AssetsParams memory params) {
        _assertVariant(r, ResponseVariant.Assets);
        (params.assets, ) = AssetsCodec.decode(r.payload);
    }

    /// @notice Decodes the execution result from an `ExecutionResult` response.
    /// @param r The `Response` struct. Must be of type `ExecutionResult`.
    /// @return params An `ExecutionResultParams` struct containing the execution result details.
    function asExecutionResult(
        Response memory r
    ) internal pure returns (ExecutionResultParams memory params) {
        _assertVariant(r, ResponseVariant.ExecutionResult);
        params.hasError = r.payload[0] != 0;
        if (params.hasError) {
            params.index = LittleEndianU32.fromLittleEndian(r.payload, 1);
            (params.err, ) = XcmErrorCodec.decodeAt(r.payload, 1 + 4);
        }
    }

    /// @notice Decodes the version from a `Version` response.
    /// @param r The `Response` struct. Must be of type `Version`.
    /// @return params A `VersionParams` struct containing the decoded version number.
    function asVersion(
        Response memory r
    ) internal pure returns (VersionParams memory params) {
        _assertVariant(r, ResponseVariant.Version);
        params.version = LittleEndianU32.fromLittleEndian(r.payload, 0);
    }

    /// @notice Decodes the pallets info from a `PalletsInfo` response.
    /// @param r The `Response` struct. Must be of type `PalletsInfo`.
    /// @return params A `PalletsInfoParams` struct containing the decoded array of `PalletInfo`.
    function asPalletsInfo(
        Response memory r
    ) internal pure returns (PalletsInfoParams memory params) {
        _assertVariant(r, ResponseVariant.PalletsInfo);
        (uint256 count, uint256 prefixSize) = Compact.decodeAt(r.payload, 0);
        params.pallets = new PalletInfo[](count);
        uint256 pos = prefixSize;
        for (uint256 i = 0; i < count; ++i) {
            uint256 read;
            (params.pallets[i], read) = PalletInfoCodec.decodeAt(
                r.payload,
                pos
            );
            pos += read;
        }
    }

    /// @notice Decodes the dispatch result from a `DispatchResult` response.
    /// @param r The `Response` struct. Must be of type `DispatchResult`.
    /// @return params A `DispatchResultParams` struct containing the decoded dispatch result.
    function asDispatchResult(
        Response memory r
    ) internal pure returns (DispatchResultParams memory params) {
        _assertVariant(r, ResponseVariant.DispatchResult);
        (params.result, ) = MaybeErrorCodeCodec.decode(r.payload);
    }

    function _assertVariant(
        Response memory r,
        ResponseVariant expected
    ) private pure {
        if (r.variant != expected) {
            revert InvalidResponseVariant(uint8(r.variant));
        }
    }
}
