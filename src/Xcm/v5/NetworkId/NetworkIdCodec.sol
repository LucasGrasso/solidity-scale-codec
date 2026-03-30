// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {NetworkId, NetworkIdType} from "./NetworkId.sol";

/// @title SCALE Codec for XCM v5 `NetworkId`
/// @notice SCALE-compliant encoder/decoder for the `NetworkId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library NetworkIdCodec {
    error InvalidNetworkIdLength();
    error InvalidNetworkIdType(uint8 nType);
    error InvalidNetworkIdPayload();

    /// @notice Encodes a `NetworkId` struct into SCALE format.
    function encode(
        NetworkId memory networkId
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(networkId.nType), networkId.payload);
    }

    /// @notice Returns the number of bytes that a `NetworkId` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `NetworkId`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `NetworkId`.
    /// @return The number of bytes that the `NetworkId` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (offset >= data.length) revert InvalidNetworkIdLength();

        uint8 nType = uint8(data[offset]);
        uint256 payloadLen;

        // Determine payload length based on type to ensure we don't over-read
        if (nType == uint8(NetworkIdType.ByGenesis)) {
            payloadLen = 32;
        } else if (nType == uint8(NetworkIdType.ByFork)) {
            payloadLen = 40; // 8 (u64) + 32 (bytes32)
        } else if (nType == uint8(NetworkIdType.Ethereum)) {
            payloadLen = Compact.encodedSizeAt(data, offset + 1);
        } else if (nType < 4) {
            payloadLen = 0; // Static variants
        } else {
            // Reserved or unknown types are invalid
            revert InvalidNetworkIdType(nType);
        }

        if (offset + 1 + payloadLen > data.length)
            revert InvalidNetworkIdLength();

        return 1 + payloadLen;
    }

    /// @notice Decodes a byte array into a `NetworkId` struct.
    /// @param data The byte array to decode.
    /// @return networkId The decoded `NetworkId` struct.
    function decode(
        bytes memory data
    ) internal pure returns (NetworkId memory networkId, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a byte array into a `NetworkId` struct.
    /// @param data The byte array to decode.
    /// @param offset The byte offset to start decoding from.
    /// @return networkId The decoded `NetworkId` struct.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (NetworkId memory networkId, uint256 bytesRead) {
        if (offset >= data.length) revert InvalidNetworkIdLength();

        uint8 nType = uint8(data[offset]);
        uint256 payloadLen = encodedSizeAt(data, offset) - 1; // Subtract 1 byte for the nType
        bytes memory payload = new bytes(payloadLen);
        for (uint256 i = 0; i < payloadLen; i++) {
            payload[i] = data[offset + 1 + i];
        }

        networkId = NetworkId({nType: NetworkIdType(nType), payload: payload});

        bytesRead = 1 + payloadLen;
    }

    /// @notice Decodes a `ByGenesis` network ID, returning the genesis hash.
    /// @param networkId The `NetworkId` struct to decode.
    /// @return genesisHash The genesis hash extracted from the network ID.
    function asByGenesis(
        NetworkId memory networkId
    ) internal pure returns (bytes32 genesisHash) {
        if (networkId.nType != NetworkIdType.ByGenesis)
            revert InvalidNetworkIdType(uint8(networkId.nType));
        if (networkId.payload.length != 32) revert InvalidNetworkIdPayload();
        return bytes32(networkId.payload);
    }

    /// @notice Decodes a `ByFork` network ID, returning the block number and hash.
    /// @param networkId The `NetworkId` struct to decode.
    /// @return chainId The chain ID extracted from the network ID.
    function asEthereum(
        NetworkId memory networkId
    ) internal pure returns (uint64 chainId) {
        if (networkId.nType != NetworkIdType.Ethereum)
            revert InvalidNetworkIdType(uint8(networkId.nType));
        if (networkId.payload.length != 8) revert InvalidNetworkIdPayload();
        (uint256 decodedChainId, ) = Compact.decode(networkId.payload);
        if (decodedChainId > type(uint64).max) revert InvalidNetworkIdPayload();
        unchecked {
            chainId = uint64(decodedChainId);
        }
    }
}
