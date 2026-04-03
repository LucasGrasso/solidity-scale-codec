// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {NetworkId, NetworkIdVariant, ByForkParams, ByGenesisParams, EthereumParams} from "./NetworkId.sol";
import {LittleEndianU64} from "../../../LittleEndian/LittleEndianU64.sol";
import {Bytes32} from "../../../Scale/Bytes.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `NetworkId`
/// @notice SCALE-compliant encoder/decoder for the `NetworkId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library NetworkIdCodec {
    error InvalidNetworkIdLength();
    error InvalidNetworkIdVariant(uint8 variant);

    /// @notice Encodes a `NetworkId` struct into SCALE format.
    function encode(
        NetworkId memory networkId
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(networkId.variant), networkId.payload);
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

        uint8 variant = uint8(data[offset]);
        uint256 payloadLen;

        // Determine payload length based on type to ensure we don't over-read
        if (variant == uint8(NetworkIdVariant.ByGenesis)) {
            payloadLen = 32;
        } else if (variant == uint8(NetworkIdVariant.ByFork)) {
            payloadLen = 40; // 8 (u64) + 32 (bytes32)
        } else if (variant == uint8(NetworkIdVariant.Ethereum)) {
            payloadLen = Compact.encodedSizeAt(data, offset + 1);
        } else if (variant < 4) {
            payloadLen = 0; // Static variants
        } else {
            // Reserved or unknown types are invalid
            revert InvalidNetworkIdVariant(variant);
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

        uint8 variant = uint8(data[offset]);
        uint256 payloadLen = encodedSizeAt(data, offset) - 1; // Subtract 1 byte for the variant
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLen);

        networkId = NetworkId({
            variant: NetworkIdVariant(variant),
            payload: payload
        });

        bytesRead = 1 + payloadLen;
    }

    /// @notice Decodes a `ByGenesis` network ID, returning the genesis hash.
    /// @param networkId The `NetworkId` struct to decode.
    /// @return params A `ByGenesisParams` struct containing the genesis hash extracted from the network ID.
    function asByGenesis(
        NetworkId memory networkId
    ) internal pure returns (ByGenesisParams memory params) {
        _assertVariant(networkId, NetworkIdVariant.ByGenesis);
        params.genesisHash = bytes32(networkId.payload);
    }

    /// @notice Decodes a `Ethereum` network ID, returning the chain ID.
    /// @param networkId The `NetworkId` struct to decode.
    /// @return params An `EthereumParams` struct containing the chain ID extracted from the network ID.
    function asEthereum(
        NetworkId memory networkId
    ) internal pure returns (EthereumParams memory params) {
        _assertVariant(networkId, NetworkIdVariant.Ethereum);
        (uint256 decodedChainId, ) = Compact.decode(networkId.payload);
        params.chainId = UnsignedUtils.toU64(decodedChainId);
    }

    /// @notice Decodes a `ByFork` network ID, returning the block number and block hash of the fork point.
    /// @param networkId The `NetworkId` struct to decode.
    /// @return params A `ByForkParams` struct containing the block number and block hash extracted from the network ID.
    function asFork(
        NetworkId memory networkId
    ) internal pure returns (ByForkParams memory params) {
        _assertVariant(networkId, NetworkIdVariant.ByFork);
        params.blockNumber = LittleEndianU64.fromLittleEndian(
            networkId.payload,
            0
        );
        params.blockHash = Bytes32.decodeAt(networkId.payload, 8);
    }

    function _assertVariant(
        NetworkId memory networkId,
        NetworkIdVariant expected
    ) private pure {
        if (networkId.variant != expected) {
            revert InvalidNetworkIdVariant(uint8(networkId.variant));
        }
    }
}
