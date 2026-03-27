// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU64} from "../../LittleEndian/LittleEndianU64.sol";

/// @dev Discriminant for the different types of NetworkIds in XCM v5.
enum NetworkType {
    /// @custom:variant Network specified by the first 32 bytes of its genesis block.
    ByGenesis,
    /// @custom:variant Network defined by the first 32-bytes of the hash and number of some block it contains.
    ByFork,
    /// @custom:variant The Polkadot Relay Chain.
    Polkadot,
    /// @custom:variant The Kusama Relay Chain.
    Kusama,
    /// @custom:variant An Ethereum-based network, identified by its chain ID.
    Ethereum,
    /// @custom:variant The Bitcoin network.
    BitcoinCore,
    /// @custom:variant The Bitcoin Cash network.
    BitcoinCash,
    /// @custom:variant The Polkadot Bulletin Chain.
    PolkadotBulletin
}

/// @notice Parameters for a `ByGenesis` network ID, containing the genesis block hash.
struct ByForkParams {
    /// @custom:property The block number of the block.
    uint64 blockNumber;
    /// @custom:property The hash of the block.
    bytes32 blockHash;
}

/// @notice Parameters for an `Ethereum` network ID, containing the chain ID.
struct EthereumParams {
    /// @custom:property The chain ID of an Ethereum network.
    uint64 chainId;
}

/// @dev Notice A global identifier of a data structure existing within consensus.
struct NetworkId {
    /// @custom:property The type of network ID, determining how to interpret the payload. See `NetworkType` enum for possible values.
    NetworkType nType;
    /// @custom:property The encoded payload containing the network identifier data, whose structure depends on the `nType`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `NetworkId`
/// @notice SCALE-compliant encoder/decoder for the `NetworkId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library NetworkIdCodec {
    error InvalidNetworkIdLength();
    error InvalidNetworkIdType(uint8 nType);
    error InvalidNetworkIdPayload();

    using LittleEndianU64 for uint64;

    /// @notice Creates a `ByGenesis` network ID.
    /// @param genesisHash The 32-byte hash of the genesis block of the network.
    /// @return A `NetworkId` struct with type `ByGenesis` and the provided genesis hash as payload.
    function byGenesis(
        bytes32 genesisHash
    ) internal pure returns (NetworkId memory) {
        return
            NetworkId({
                nType: NetworkType.ByGenesis,
                payload: abi.encodePacked(genesisHash)
            });
    }

    /// @notice Creates a `ByFork` network ID.
    /// @param blockNumber The block number of the fork point.
    /// @param blockHash The 32-byte hash of the block at the fork point.
    /// @return A `NetworkId` struct with type `ByFork` and the provided block number and hash encoded in the payload.
    function byFork(
        uint64 blockNumber,
        bytes32 blockHash
    ) internal pure returns (NetworkId memory) {
        return
            NetworkId({
                nType: NetworkType.ByFork,
                payload: abi.encodePacked(blockNumber.toLE(), blockHash)
            });
    }

    /// @notice Creates a `Polkadot` network ID.
    /// @return A `NetworkId` struct with type `Polkadot` and an empty payload.
    function polkadot() internal pure returns (NetworkId memory) {
        return NetworkId({nType: NetworkType.Polkadot, payload: ""});
    }

    /// @notice Creates a `Kusama` network ID.
    /// @return A `NetworkId` struct with type `Kusama` and an empty payload.
    function kusama() internal pure returns (NetworkId memory) {
        return NetworkId({nType: NetworkType.Kusama, payload: ""});
    }

    /// @notice Creates an `Ethereum` network ID.
    /// @param chainId The chain ID of the Ethereum network.
    function ethereum(uint64 chainId) internal pure returns (NetworkId memory) {
        return
            NetworkId({
                nType: NetworkType.Ethereum,
                payload: abi.encodePacked(chainId.toLE())
            });
    }

    /// @notice Encodes a `NetworkId` struct into SCALE format.
    function encode(
        NetworkId memory networkId
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(networkId.nType), networkId.payload);
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
        uint256 payloadLen;

        // Determine payload length based on type to ensure we don't over-read
        if (nType == uint8(NetworkType.ByGenesis)) {
            payloadLen = 32;
        } else if (nType == uint8(NetworkType.ByFork)) {
            payloadLen = 40; // 8 (u64) + 32 (bytes32)
        } else if (nType == uint8(NetworkType.Ethereum)) {
            payloadLen = 8; // 8 (u64)
        } else if (nType <= 7) {
            payloadLen = 0; // Static variants
        } else {
            revert InvalidNetworkIdType(nType);
        }

        if (offset + 1 + payloadLen > data.length)
            revert InvalidNetworkIdLength();

        bytes memory payload = new bytes(payloadLen);
        for (uint256 i = 0; i < payloadLen; i++) {
            payload[i] = data[offset + 1 + i];
        }

        networkId = NetworkId({nType: NetworkType(nType), payload: payload});

        bytesRead = 1 + payloadLen;
    }

    /// @notice Decodes a `ByGenesis` network ID, returning the genesis hash.
    /// @param networkId The `NetworkId` struct to decode.
    /// @return genesisHash The genesis hash extracted from the network ID.
    function decodeByGenesis(
        NetworkId memory networkId
    ) internal pure returns (bytes32 genesisHash) {
        if (networkId.nType != NetworkType.ByGenesis)
            revert InvalidNetworkIdType(uint8(networkId.nType));
        if (networkId.payload.length != 32) revert InvalidNetworkIdPayload();
        return bytes32(networkId.payload);
    }

    /// @notice Decodes a `ByFork` network ID, returning the block number and hash.
    /// @param networkId The `NetworkId` struct to decode.
    /// @return chainId The chain ID extracted from the network ID.
    function decodeEthereum(
        NetworkId memory networkId
    ) internal pure returns (uint64 chainId) {
        if (networkId.nType != NetworkType.Ethereum)
            revert InvalidNetworkIdType(uint8(networkId.nType));
        if (networkId.payload.length != 8) revert InvalidNetworkIdPayload();
        chainId = LittleEndianU64.fromLE(networkId.payload, 0);
    }
}
