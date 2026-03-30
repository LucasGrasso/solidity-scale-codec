// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {LittleEndianU64} from "../../../LittleEndian/LittleEndianU64.sol";

/// @dev Discriminant for the different types of NetworkIds in XCM v5.
enum NetworkIdType {
    /// @custom:variant Network specified by the first 32 bytes of its genesis block.
    ByGenesis,
    /// @custom:variant Network defined by the first 32-bytes of the hash and number of some block it contains.
    ByFork,
    /// @custom:variant The Polkadot Relay Chain.
    Polkadot,
    /// @custom:variant The Kusama Relay Chain.
    Kusama,
    /// @custom:variant Reserved. Do not Use.
    _Reserved4,
    /// @custom:variant Reserved. Do not Use.
    _Reserved5,
    /// @custom:variant Reserved. Do not Use.
    _Reserved6,
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
    /// @custom:property The type of network ID, determining how to interpret the payload. See `NetworkIdType` enum for possible values.
    NetworkIdType nType;
    /// @custom:property The encoded payload containing the network identifier data, whose structure depends on the `nType`.
    bytes payload;
}

using LittleEndianU64 for uint64;

// ============ Factory Functions ============

/// @notice Creates a `ByGenesis` network ID.
/// @param genesisHash The 32-byte hash of the genesis block of the network.
/// @return A `NetworkId` struct with type `ByGenesis` and the provided genesis hash as payload.
function byGenesis(bytes32 genesisHash) pure returns (NetworkId memory) {
    return
        NetworkId({
            nType: NetworkIdType.ByGenesis,
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
) pure returns (NetworkId memory) {
    return
        NetworkId({
            nType: NetworkIdType.ByFork,
            payload: abi.encodePacked(blockNumber.toLittleEndian(), blockHash)
        });
}

/// @notice Creates a `Polkadot` network ID.
/// @return A `NetworkId` struct with type `Polkadot` and an empty payload.
function polkadot() pure returns (NetworkId memory) {
    return NetworkId({nType: NetworkIdType.Polkadot, payload: ""});
}

/// @notice Creates a `Kusama` network ID.
/// @return A `NetworkId` struct with type `Kusama` and an empty payload.
function kusama() pure returns (NetworkId memory) {
    return NetworkId({nType: NetworkIdType.Kusama, payload: ""});
}

/// @notice Creates an `Ethereum` network ID.
/// @param chainId The chain ID of the Ethereum network.
function ethereum(uint64 chainId) pure returns (NetworkId memory) {
    return
        NetworkId({
            nType: NetworkIdType.Ethereum,
            payload: Compact.encode(chainId)
        });
}
