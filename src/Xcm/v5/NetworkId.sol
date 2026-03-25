// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU64} from "../../Scale/Unsigned/LittleEndianU64.sol";

/// @title SCALE Codec for XCM v5 `NetworkId`
/// @notice SCALE-compliant encoder/decoder for the `NetworkId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library NetworkId {
    error InvalidNetworkIdLength();
    error InvalidNetworkIdType(uint8 nType);
    error InvalidNetworkIdPayload();

    using LittleEndianU64 for uint64;

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

    struct ByForkParams {
        uint64 blockNumber;
        bytes32 blockHash;
    }

    struct EthereumParams {
        uint64 chainId;
    }

    // The wrapper struct
    struct NetworkId {
        NetworkType nType;
        bytes payload;
    }

    /// @notice Creates a `ByGenesis` network ID.
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
    function polkadot() internal pure returns (NetworkId memory) {
        return NetworkId({nType: NetworkType.Polkadot, payload: ""});
    }

    /// @notice Creates a `Kusama` network ID.
    function kusama() internal pure returns (NetworkId memory) {
        return NetworkId({nType: NetworkType.Kusama, payload: ""});
    }

    /// @notice Creates an `Ethereum` network ID.
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
    /// @return blockNumber The block number extracted from the network ID.
    function decodeEthereum(
        NetworkId memory networkId
    ) internal pure returns (uint64 chainId) {
        if (networkId.nType != NetworkType.Ethereum)
            revert InvalidNetworkIdType(uint8(networkId.nType));
        if (networkId.payload.length != 8) revert InvalidNetworkIdPayload();

        assembly {
            chainId := mload(add(networkId.payload, 32))
        }
        return LittleEndianU64.fromLE(chainId);
    }
}
