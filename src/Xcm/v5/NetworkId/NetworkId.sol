// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact/Compact.sol";
import {LittleEndianU64} from "../../../LittleEndian/LittleEndianU64.sol";

/// @dev Discriminant for the different types of NetworkIds in XCM v5.
enum NetworkIdVariant {
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

/// @notice Parameters for a `ByGenesis` network ID.
struct ByGenesisParams {
    /// @custom:property The 32-byte genesis block hash.
    bytes32 genesisHash;
}

/// @dev Notice A global identifier of a data structure existing within consensus.
struct NetworkId {
    /// @custom:property The type of network ID, determining how to interpret the payload. See `NetworkIdVariant` enum for possible values.
    NetworkIdVariant variant;
    /// @custom:property The encoded payload containing the network identifier data, whose structure depends on the `variant`.
    bytes payload;
}

using LittleEndianU64 for uint64;

// ============ Factory Functions ============

/// @notice Creates a `ByGenesis` network ID.
/// @param params Parameters for the by-genesis variant.
/// @return A `NetworkId` struct with type `ByGenesis` and the provided genesis hash as payload.
function byGenesis(
    ByGenesisParams memory params
) pure returns (NetworkId memory) {
    return
        NetworkId({
            variant: NetworkIdVariant.ByGenesis,
            payload: abi.encodePacked(params.genesisHash)
        });
}

/// @notice Creates a `ByFork` network ID.
/// @param params Parameters for the by-fork variant.
/// @return A `NetworkId` struct with type `ByFork` and the provided block number and hash encoded in the payload.
function byFork(ByForkParams memory params) pure returns (NetworkId memory) {
    return
        NetworkId({
            variant: NetworkIdVariant.ByFork,
            payload: abi.encodePacked(
                params.blockNumber.toLittleEndian(),
                params.blockHash
            )
        });
}

/// @notice Creates a `Polkadot` network ID.
/// @return A `NetworkId` struct with type `Polkadot` and an empty payload.
function polkadot() pure returns (NetworkId memory) {
    return NetworkId({variant: NetworkIdVariant.Polkadot, payload: ""});
}

/// @notice Creates a `Kusama` network ID.
/// @return A `NetworkId` struct with type `Kusama` and an empty payload.
function kusama() pure returns (NetworkId memory) {
    return NetworkId({variant: NetworkIdVariant.Kusama, payload: ""});
}

/// @notice Creates an `Ethereum` network ID.
/// @param params Parameters for the ethereum variant.
function ethereum(
    EthereumParams memory params
) pure returns (NetworkId memory) {
    return
        NetworkId({
            variant: NetworkIdVariant.Ethereum,
            payload: Compact.encode(params.chainId)
        });
}
