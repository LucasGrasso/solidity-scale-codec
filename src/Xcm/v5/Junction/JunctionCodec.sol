// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BodyId} from "../BodyId/BodyId.sol";
import {BodyIdCodec} from "../BodyId/BodyIdCodec.sol";
import {BodyPart} from "../BodyPart/BodyPart.sol";
import {BodyPartCodec} from "../BodyPart/BodyPartCodec.sol";
import {NetworkId} from "../NetworkId/NetworkId.sol";
import {NetworkIdCodec} from "../NetworkId/NetworkIdCodec.sol";
import {Bytes32} from "../../../Scale/Bytes.sol";
import {Address} from "../../../Scale/Address.sol";
import {Compact} from "../../../Scale/Compact.sol";
import {
    Junction,
    JunctionType,
    AccountId32Params,
    PluralityParams,
    AccountIndex64Params,
    AccountKey20Params,
    GeneralKeyParams
} from "./Junction.sol";

/// @title SCALE Codec for XCM v5 `Junction`
/// @notice SCALE-compliant encoder/decoder for the `Junction` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library JunctionCodec {
    error InvalidJunctionLength();
    error InvalidJunctionType(uint8 jType);
    error InvalidJunctionPayload();

    /// @notice Encodes a `Junction` struct into a byte array suitable for SCALE encoding.
    /// @param junction The `Junction` struct to encode.
    /// @return A byte array representing the SCALE-encoded junction, including its type and payload.
    function encode(
        Junction memory junction
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(junction.jType), junction.payload);
    }

    /// @notice Returns the number of bytes that a `Junction` struct would occupy when SCALE-encoded, starting from the specified offset.
    /// @param data The byte array containing the SCALE-encoded junction data.
    /// @param offset The byte offset to start calculating from.
    /// @return The number of bytes that the `Junction` struct would occupy when SCALE-encoded, including the type and payload.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (offset >= data.length) revert InvalidJunctionLength();
        uint8 jType;
        assembly {
            jType := shr(248, mload(add(add(data, 32), offset)))
        }
        uint256 payloadLength;
        ++offset; // Move past the type byte
        if (jType == uint8(JunctionType.Parachain)) {
            payloadLength = Compact.encodedSizeAt(data, offset);
        } else if (jType == uint8(JunctionType.AccountId32)) {
            payloadLength = _innerNetworkIdSize(data, offset) + 32; // for the account ID;
        } else if (jType == uint8(JunctionType.AccountIndex64)) {
            payloadLength = _innerNetworkIdSize(data, offset);
            payloadLength += Compact.encodedSizeAt(
                data,
                offset + payloadLength
            ); // for the account index
        } else if (jType == uint8(JunctionType.AccountKey20)) {
            payloadLength = _innerNetworkIdSize(data, offset) + 20; // for the account key;
        } else if (jType == uint8(JunctionType.PalletInstance)) {
            payloadLength = 1;
        } else if (jType == uint8(JunctionType.GeneralIndex)) {
            payloadLength = Compact.encodedSizeAt(data, offset);
        } else if (jType == uint8(JunctionType.GeneralKey)) {
            if (offset >= data.length) revert InvalidJunctionLength();
            uint8 length = uint8(data[offset]);
            payloadLength = 1 + length; // 1 byte for the length + the key bytes
        } else if (
            jType == uint8(JunctionType.OnlyChild) ||
            jType == uint8(JunctionType.GlobalConsensus)
        ) {
            payloadLength = 0;
        } else if (jType == uint8(JunctionType.Plurality)) {
            uint256 innerLength = BodyIdCodec.encodedSizeAt(data, offset);
            payloadLength =
                innerLength +
                BodyPartCodec.encodedSizeAt(data, offset + innerLength);
        } else {
            revert InvalidJunctionType(jType);
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
        if (offset >= data.length) revert InvalidJunctionLength();
        uint8 jType;
        assembly {
            jType := shr(248, mload(add(add(data, 32), offset)))
        }
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // Subtract 1 byte for the type
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; i++) {
            payload[i] = data[offset + 1 + i];
        }
        junction = Junction({jType: JunctionType(jType), payload: payload});
        bytesRead = 1 + payload.length;
    }

    /// @notice Decodes a `Parachain` junction from a given `Junction` struct, extracting the parachain ID.
    /// @param junction The `Junction` struct to decode, which should represent a `Parachain` junction.
    /// @return parachainId The ID of the parachain extracted from the junction's payload.
    function asParachain(
        Junction memory junction
    ) internal pure returns (uint32 parachainId) {
        if (junction.jType != JunctionType.Parachain)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length != 4) revert InvalidJunctionPayload();
        (uint256 decodedParachain, ) = Compact.decode(junction.payload);
        if (decodedParachain > type(uint32).max) {
            revert InvalidJunctionPayload();
        }
        unchecked {
            parachainId = uint32(decodedParachain);
        }
    }

    /// @notice Decodes an `AccountId32` junction from a given `Junction` struct, extracting the network information and account ID.
    /// @param junction The `Junction` struct to decode, which should represent an `AccountId32` junction.
    /// @return params An `AccountId32Params` struct containing the decoded network information and account ID.
    function asAccountId32(
        Junction memory junction
    ) internal pure returns (AccountId32Params memory params) {
        if (junction.jType != JunctionType.AccountId32)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length != 33 && junction.payload.length != 34)
            revert InvalidJunctionPayload();
        bool hasNetwork = junction.payload[0] != 0;
        uint256 offset = 1;
        NetworkId memory network;
        uint256 bytesRead;
        if (hasNetwork) {
            (network, bytesRead) = NetworkIdCodec.decodeAt(
                junction.payload,
                offset
            );
            offset += bytesRead;
        }
        bytes32 id = Bytes32.decodeAt(junction.payload, offset);
        return
            AccountId32Params({
                hasNetwork: hasNetwork,
                network: network,
                id: id
            });
    }

    /// @notice Decodes an `AccountIndex64` junction from a given `Junction` struct, extracting the network information and account index.
    /// @param junction The `Junction` struct to decode, which should represent an `AccountIndex64` junction.
    /// @return params An `AccountIndex64Params` struct containing the decoded network information and account index.
    function asAccountIndex64(
        Junction memory junction
    ) internal pure returns (AccountIndex64Params memory params) {
        if (junction.jType != JunctionType.AccountIndex64)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length != 9 && junction.payload.length != 10)
            revert InvalidJunctionPayload();
        bool hasNetwork = junction.payload[0] != 0;
        uint256 offset = 1;
        NetworkId memory network;
        uint256 bytesRead;
        if (hasNetwork) {
            (network, bytesRead) = NetworkIdCodec.decodeAt(
                junction.payload,
                offset
            );
            offset += bytesRead;
        }
        (uint256 decodedIndex, ) = Compact.decodeAt(junction.payload, offset);
        if (decodedIndex > type(uint64).max) {
            revert InvalidJunctionPayload();
        }
        uint64 index;
        unchecked {
            index = uint64(decodedIndex);
        }
        return
            AccountIndex64Params({
                hasNetwork: hasNetwork,
                network: network,
                index: index
            });
    }

    /// @notice Decodes an `AccountKey20` junction from a given `Junction` struct, extracting the network information and account key.
    /// @param junction The `Junction` struct to decode, which should represent an `AccountKey20` junction.
    /// @return params An `AccountKey20Params` struct containing the decoded network information and account key.
    function asAccountKey20(
        Junction memory junction
    ) internal pure returns (AccountKey20Params memory params) {
        if (junction.jType != JunctionType.AccountKey20)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length != 21 && junction.payload.length != 22)
            revert InvalidJunctionPayload();
        bool hasNetwork = junction.payload[0] != 0;
        uint256 offset = 1;
        NetworkId memory network;
        uint256 bytesRead;
        if (hasNetwork) {
            (network, bytesRead) = NetworkIdCodec.decodeAt(
                junction.payload,
                offset
            );
            offset += bytesRead;
        }
        address key = Address.decodeAt(junction.payload, offset);
        return
            AccountKey20Params({
                hasNetwork: hasNetwork,
                network: network,
                key: key
            });
    }

    /// @notice Decodes a `PalletInstance` junction from a given `Junction` struct, extracting the pallet instance index.
    /// @param junction The `Junction` struct to decode, which should represent a `PalletInstance` junction.
    /// @return instance The index of the pallet instance extracted from the junction's payload.
    function asPalletInstance(
        Junction memory junction
    ) internal pure returns (uint8 instance) {
        if (junction.jType != JunctionType.PalletInstance)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length != 1) revert InvalidJunctionPayload();
        return uint8(junction.payload[0]);
    }

    /// @notice Decodes a `GeneralIndex` junction from a given `Junction` struct, extracting the general index.
    /// @param junction The `Junction` struct to decode, which should represent a `GeneralIndex` junction.
    /// @return index The general index extracted from the junction's payload.
    function asGeneralIndex(
        Junction memory junction
    ) internal pure returns (uint128 index) {
        if (junction.jType != JunctionType.GeneralIndex)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length == 0) revert InvalidJunctionPayload();
        (uint256 decodedIndex, ) = Compact.decode(junction.payload);
        if (decodedIndex > type(uint128).max) {
            revert InvalidJunctionPayload();
        }
        unchecked {
            index = uint128(decodedIndex);
        }
    }

    /// @notice Decodes a `GeneralKey` junction from a given `Junction` struct, extracting the key.
    /// @param junction The `Junction` struct to decode, which should represent a `GeneralKey` junction.
    /// @return params A `GeneralKeyParams` struct containing the length and key extracted from the junction's payload.
    function asGeneralKey(
        Junction memory junction
    ) internal pure returns (GeneralKeyParams memory params) {
        if (junction.jType != JunctionType.GeneralKey)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length == 0) revert InvalidJunctionPayload();
        uint8 length = uint8(junction.payload[0]);
        if (length == 0 || length > 32 || junction.payload.length != length + 1)
            revert InvalidJunctionPayload();
        bytes32 key = Bytes32.decodeAt(junction.payload, 1);
        return GeneralKeyParams({length: length, key: key});
    }

    /// @notice Decodes a `Plurality` junction from a given `Junction` struct, extracting the body ID and body part.
    /// @param junction The `Junction` struct to decode, which should represent a `Plurality` junction.
    /// @return params A `PluralityParams` struct containing the body ID and body part extracted from the junction's payload.
    function asPlurality(
        Junction memory junction
    ) internal pure returns (PluralityParams memory params) {
        if (junction.jType != JunctionType.Plurality)
            revert InvalidJunctionType(uint8(junction.jType));
        if (junction.payload.length == 0) revert InvalidJunctionPayload();
        uint256 offset = 0;
        BodyId memory id;
        uint256 bytesRead;
        (id, bytesRead) = BodyIdCodec.decodeAt(junction.payload, offset);
        offset += bytesRead;
        BodyPart memory part;
        (part, bytesRead) = BodyPartCodec.decodeAt(junction.payload, offset);
        return PluralityParams({id: id, part: part});
    }

    /// @notice Decodes an `GlobalConsensus` junction from a given `Junction` struct and extracts the `NetworkId`.
    /// @param junction The `Junction` struct to decode, which should represent a `GlobalConsensus` junction.
    /// @return networkId The `NetworkId` extracted from the junction's payload, representing the global network's consensus.
    function asGlobalConsensus(
        Junction memory junction
    ) internal pure returns (NetworkId memory networkId) {
        if (junction.jType != JunctionType.GlobalConsensus)
            revert InvalidJunctionType(uint8(junction.jType));
        (networkId, ) = NetworkIdCodec.decode(junction.payload);
    }

    function _innerNetworkIdSize(
        bytes memory data,
        uint256 offset
    ) private pure returns (uint256) {
        if (offset >= data.length) revert InvalidJunctionLength();
        bool hasNetwork = data[offset] != 0;
        uint256 size = 1; // for the hasNetwork byte
        if (hasNetwork) {
            size += NetworkIdCodec.encodedSizeAt(data, offset + size);
        }
        return size;
    }
}
