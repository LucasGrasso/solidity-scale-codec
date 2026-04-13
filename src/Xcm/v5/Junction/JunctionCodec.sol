// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BodyIdCodec} from "../BodyId/BodyIdCodec.sol";
import {BodyPartCodec} from "../BodyPart/BodyPartCodec.sol";
import {NetworkIdCodec} from "../NetworkId/NetworkIdCodec.sol";
import {Bytes32} from "../../../Scale/Bytes.sol";
import {Address} from "../../../Scale/Address.sol";
import {Compact} from "../../../Scale/Compact.sol";
import {Junction, JunctionVariant, ParachainParams, AccountId32Params, PluralityParams, AccountIndex64Params, AccountKey20Params, GeneralKeyParams, PalletInstanceParams, GeneralIndexParams, GlobalConsensusParams} from "./Junction.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `Junction`
/// @notice SCALE-compliant encoder/decoder for the `Junction` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library JunctionCodec {
    error InvalidJunctionLength();
    error InvalidJunctionVariant(uint8 variant);
    error InvalidJunctionPayload();

    /// @notice Encodes a `Junction` struct into a byte array suitable for SCALE encoding.
    /// @param junction The `Junction` struct to encode.
    /// @return A byte array representing the SCALE-encoded junction, including its type and payload.
    function encode(
        Junction memory junction
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(junction.variant), junction.payload);
    }

    /// @notice Returns the number of bytes that a `Junction` struct would occupy when SCALE-encoded, starting from the specified offset.
    /// @param data The byte array containing the SCALE-encoded junction data.
    /// @param offset The byte offset to start calculating from.
    /// @return The number of bytes that the `Junction` struct would occupy when SCALE-encoded, including the type and payload.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (!(offset < data.length)) revert InvalidJunctionLength();
        uint8 variant = uint8(data[offset]);
        uint256 payloadLength;
        ++offset; // Move past the type byte
        if (variant == uint8(JunctionVariant.Parachain)) {
            payloadLength = Compact.encodedSizeAt(data, offset);
        } else if (variant == uint8(JunctionVariant.AccountId32)) {
            payloadLength = _innerNetworkIdSize(data, offset) + 32; // for the account ID;
        } else if (variant == uint8(JunctionVariant.AccountIndex64)) {
            payloadLength = _innerNetworkIdSize(data, offset);
            payloadLength += Compact.encodedSizeAt(
                data,
                offset + payloadLength
            ); // for the account index
        } else if (variant == uint8(JunctionVariant.AccountKey20)) {
            payloadLength = _innerNetworkIdSize(data, offset) + 20; // for the account key;
        } else if (variant == uint8(JunctionVariant.PalletInstance)) {
            payloadLength = 1;
        } else if (variant == uint8(JunctionVariant.GeneralIndex)) {
            payloadLength = Compact.encodedSizeAt(data, offset);
        } else if (variant == uint8(JunctionVariant.GeneralKey)) {
            if (!(offset < data.length)) revert InvalidJunctionLength();
            uint8 length = uint8(data[offset]);
            if (length == 0 || length > 32) revert InvalidJunctionPayload();
            payloadLength = 1 + 32; // 1 byte for the length + the fixed key bytes
        } else if (variant == uint8(JunctionVariant.OnlyChild)) {
            payloadLength = 0;
        } else if (variant == uint8(JunctionVariant.GlobalConsensus)) {
            payloadLength = NetworkIdCodec.encodedSizeAt(data, offset);
        } else if (variant == uint8(JunctionVariant.Plurality)) {
            uint256 innerLength = BodyIdCodec.encodedSizeAt(data, offset);
            payloadLength =
                innerLength +
                BodyPartCodec.encodedSizeAt(data, offset + innerLength);
        } else {
            revert InvalidJunctionVariant(variant);
        }

        return 1 + payloadLength; // 1 byte for the type + payload length
    }

    /// @notice Decodes a byte array into a `Junction` struct, starting from the specified offset.
    /// @param data The byte array containing the SCALE-encoded junction data.
    /// @return junction A `Junction` struct representing the decoded junction, including its type and payload.
    /// @return bytesRead The total number of bytes read during decoding, including the type and payload.
    function decode(
        bytes memory data
    ) internal pure returns (Junction memory junction, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a byte array into a `Junction` struct, starting from the specified offset.
    /// @param data The byte array containing the SCALE-encoded junction data.
    /// @param offset The byte offset to start decoding from.
    /// @return junction A `Junction` struct representing the decoded junction, including its type and payload.
    /// @return bytesRead The total number of bytes read during decoding, including the type and payload.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Junction memory junction, uint256 bytesRead) {
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // Subtract 1 byte for the type
        uint8 variant = uint8(data[offset]);
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        junction = Junction({
            variant: JunctionVariant(variant),
            payload: payload
        });
        bytesRead = 1 + payload.length;
    }

    /// @notice Decodes a `Parachain` junction from a given `Junction` struct, extracting the parachain ID.
    /// @param junction The `Junction` struct to decode, which should represent a `Parachain` junction.
    /// @return params A `ParachainParams` struct containing the decoded parachain ID.
    function asParachain(
        Junction memory junction
    ) internal pure returns (ParachainParams memory params) {
        _assertVariant(junction, JunctionVariant.Parachain);
        (uint256 decodedParachain, ) = Compact.decode(junction.payload);
        params.parachainId = UnsignedUtils.toU32(decodedParachain);
    }

    /// @notice Decodes an `AccountId32` junction from a given `Junction` struct, extracting the network information and account ID.
    /// @param junction The `Junction` struct to decode, which should represent an `AccountId32` junction.
    /// @return params An `AccountId32Params` struct containing the decoded network information and account ID.
    function asAccountId32(
        Junction memory junction
    ) internal pure returns (AccountId32Params memory params) {
        _assertVariant(junction, JunctionVariant.AccountId32);
        params.hasNetwork = junction.payload[0] != 0;
        uint256 offset = 1;
        uint256 bytesRead;
        if (params.hasNetwork) {
            (params.network, bytesRead) = NetworkIdCodec.decodeAt(
                junction.payload,
                offset
            );
            offset += bytesRead;
        }
        params.id = Bytes32.decodeAt(junction.payload, offset);
    }

    /// @notice Decodes an `AccountIndex64` junction from a given `Junction` struct, extracting the network information and account index.
    /// @param junction The `Junction` struct to decode, which should represent an `AccountIndex64` junction.
    /// @return params An `AccountIndex64Params` struct containing the decoded network information and account index.
    function asAccountIndex64(
        Junction memory junction
    ) internal pure returns (AccountIndex64Params memory params) {
        _assertVariant(junction, JunctionVariant.AccountIndex64);
        params.hasNetwork = junction.payload[0] != 0;
        uint256 offset = 1;
        uint256 bytesRead;
        if (params.hasNetwork) {
            (params.network, bytesRead) = NetworkIdCodec.decodeAt(
                junction.payload,
                offset
            );
            offset += bytesRead;
        }
        (uint256 decodedIndex, ) = Compact.decodeAt(junction.payload, offset);
        params.index = UnsignedUtils.toU64(decodedIndex);
    }

    /// @notice Decodes an `AccountKey20` junction from a given `Junction` struct, extracting the network information and account key.
    /// @param junction The `Junction` struct to decode, which should represent an `AccountKey20` junction.
    /// @return params An `AccountKey20Params` struct containing the decoded network information and account key.
    function asAccountKey20(
        Junction memory junction
    ) internal pure returns (AccountKey20Params memory params) {
        _assertVariant(junction, JunctionVariant.AccountKey20);
        params.hasNetwork = junction.payload[0] != 0;
        uint256 offset = 1;
        uint256 bytesRead;
        if (params.hasNetwork) {
            (params.network, bytesRead) = NetworkIdCodec.decodeAt(
                junction.payload,
                offset
            );
            offset += bytesRead;
        }
        params.key = Address.decodeAt(junction.payload, offset);
    }

    /// @notice Decodes a `PalletInstance` junction from a given `Junction` struct, extracting the pallet instance index.
    /// @param junction The `Junction` struct to decode, which should represent a `PalletInstance` junction.
    /// @return params A `PalletInstanceParams` struct containing the decoded pallet instance index.
    function asPalletInstance(
        Junction memory junction
    ) internal pure returns (PalletInstanceParams memory params) {
        _assertVariant(junction, JunctionVariant.PalletInstance);
        params.instance = uint8(junction.payload[0]);
    }

    /// @notice Decodes a `GeneralIndex` junction from a given `Junction` struct, extracting the general index.
    /// @param junction The `Junction` struct to decode, which should represent a `GeneralIndex` junction.
    /// @return params A `GeneralIndexParams` struct containing the decoded general index.
    function asGeneralIndex(
        Junction memory junction
    ) internal pure returns (GeneralIndexParams memory params) {
        _assertVariant(junction, JunctionVariant.GeneralIndex);
        (uint256 decodedIndex, ) = Compact.decode(junction.payload);
        params.index = UnsignedUtils.toU128(decodedIndex);
    }

    /// @notice Decodes a `GeneralKey` junction from a given `Junction` struct, extracting the key.
    /// @param junction The `Junction` struct to decode, which should represent a `GeneralKey` junction.
    /// @return params A `GeneralKeyParams` struct containing the length and key extracted from the junction's payload.
    function asGeneralKey(
        Junction memory junction
    ) internal pure returns (GeneralKeyParams memory params) {
        _assertVariant(junction, JunctionVariant.GeneralKey);
        params.length = uint8(junction.payload[0]);
        params.key = Bytes32.decodeAt(junction.payload, 1);
    }

    /// @notice Decodes a `Plurality` junction from a given `Junction` struct, extracting the body ID and body part.
    /// @param junction The `Junction` struct to decode, which should represent a `Plurality` junction.
    /// @return params A `PluralityParams` struct containing the body ID and body part extracted from the junction's payload.
    function asPlurality(
        Junction memory junction
    ) internal pure returns (PluralityParams memory params) {
        _assertVariant(junction, JunctionVariant.Plurality);
        uint256 offset = 0;
        uint256 bytesRead;
        (params.id, bytesRead) = BodyIdCodec.decodeAt(junction.payload, offset);
        offset += bytesRead;
        (params.part, bytesRead) = BodyPartCodec.decodeAt(
            junction.payload,
            offset
        );
    }

    /// @notice Decodes a `GlobalConsensus` junction from a given `Junction` struct, extracting the network information.
    /// @param junction The `Junction` struct to decode, which should represent a `GlobalConsensus` junction.
    /// @return params A `GlobalConsensusParams` struct containing the decoded
    function asGlobalConsensus(
        Junction memory junction
    ) internal pure returns (GlobalConsensusParams memory params) {
        _assertVariant(junction, JunctionVariant.GlobalConsensus);
        (params.network, ) = NetworkIdCodec.decode(junction.payload);
    }

    function _innerNetworkIdSize(
        bytes memory data,
        uint256 offset
    ) private pure returns (uint256) {
        if (!(offset < data.length)) revert InvalidJunctionLength();
        bool hasNetwork = data[offset] != 0;
        uint256 size = 1; // for the hasNetwork byte
        if (hasNetwork) {
            size += NetworkIdCodec.encodedSizeAt(data, offset + size);
        }
        return size;
    }

    function _assertVariant(
        Junction memory junction,
        JunctionVariant expected
    ) private pure {
        if (junction.variant != expected) {
            revert InvalidJunctionVariant(uint8(junction.variant));
        }
    }
}
