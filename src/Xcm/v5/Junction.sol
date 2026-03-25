// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {NetworkId} from "./NetworkId.sol";
import {Address} from "../../Scale/Address.sol";
import {LittleEndianU32} from "../../Scale/Unsigned/LittleEndianU32.sol";
import {LittleEndianU64} from "../../Scale/Unsigned/LittleEndianU64.sol";

/// @title SCALE Codec for XCM v5 `Junction`
/// @notice SCALE-compliant encoder/decoder for the `Junction` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library Junction {
	error InvalidJunctionLength();
	error InvalidJunctionType(uint8 jType);
	error InvalidJunctionPayload();

	using Address for address;
	using LittleEndianU32 for uint32;
	using LittleEndianU64 for uint64;

	/// @dev Discriminant for the different types of junctions in XCM v5. Each variant corresponds to a specific structure of the payload.
    enum JunctionType {
		/// @custom:variant An indexed parachain belonging to and operated by the context.
        Parachain,
		/// @custom:variantA 32-byte identifier for an account of a specific network that is respected as a sovereign endpoint within the context.
        AccountId32,
		/// @custom:variant Generally used when the context is a Frame-based chain.
        AccountIndex64,
		/// @custom:variant A 20-byte identifier for an account of a specific network that is respected as a sovereign endpoint within the context.
        AccountKey20,
		/// @custom:variant An instanced, indexed pallet that forms a constituent part of the context.
        PalletInstance,
		/*
			> The following are left unimplemented.
			GeneralIndex(u128),
			GeneralKey {
				length: u8,
				data: [u8; 32],
			},
			OnlyChild,
			Plurality {
				id: BodyId,
				part: BodyPart,
			},
			GlobalConsensus(NetworkId),
		*/
    }

    struct AccountId32Params {
        bool hasNetwork;
        NetworkId network;
        bytes32 id;
    }

    struct AccountIndex64Params {
        bool hasNetwork;
        NetworkId network;
        uint64 index;
    }

    struct AccountKey20Params {
        bool hasNetwork;
        NetworkId network;
        address key; // bytes20 maps to address in Solidity
    }

    // The wrapper struct
    struct Junction {
        /// @custom:property jType The type of the junction, determining how to interpret the payload.
        JunctionType jType;
        /// @custom:property payload The SCALE-encoded data specific to the junction type. The structure of this data varies based on `jType`.
        bytes payload;
    }

	/// @notice Creates a `Parachain` junction with the given parachain ID.
	/// @param parachainId The ID of the parachain to be represented in the junction.
	/// @return A `Junction` struct representing the parachain junction.
	function parachain(uint32 parachainId) internal pure returns (Junction memory) {
		return Junction({
			jType: JunctionType.Parachain,
			payload: parachainId.toLE()
		});
	}

	/// @notice Creates an `AccountId32` junction with the specified parameters.
	/// @param hasNetwork A boolean indicating whether the junction includes network information.
	/// @param network The `NetworkId` associated with the account, if `hasNetwork` is true.
	/// @param id The 32-byte identifier for the account.
	/// @return A `Junction` struct representing the `AccountId32` junction with the provided parameters.
	function accountId32(bool hasNetwork, NetworkId network, bytes32 id) internal pure returns (Junction memory) {
		return Junction({
			jType: JunctionType.AccountId32,
			payload: abi.encodePacked(hasNetwork, network.encode(), abi.encodePacked(id))
		});
	}

	/// @notice Creates an `AccountIndex64` junction with the specified parameters.
	/// @param hasNetwork A boolean indicating whether the junction includes network information.
	/// @param network The `NetworkId` associated with the account, if `hasNetwork` is true.
	/// @param index The 64-bit index identifier for the account.
	/// @return A `Junction` struct representing the `AccountIndex64` junction with the provided parameters.
	function accountIndex64(bool hasNetwork, NetworkId network, uint64 index) internal pure returns (Junction memory) {
		return Junction({
			jType: JunctionType.AccountIndex64,
			payload: abi.encodePacked(hasNetwork, network.encode(), index.toLE())
		});
	}

	/// @notice Creates an `AccountKey20` junction with the specified parameters.
	/// @param hasNetwork A boolean indicating whether the junction includes network information.
	/// @param network The `NetworkId` associated with the account, if `hasNetwork` is true.
	/// @param key The 20-byte key identifier for the account, represented as an `address` in Solidity.
	/// @return A `Junction` struct representing the `AccountKey20` junction with the provided parameters.
	function accountKey20(bool hasNetwork, NetworkId network, address key) internal pure returns (Junction memory) {
		return Junction({
			jType: JunctionType.AccountKey20,
			payload: abi.encodePacked(hasNetwork, network.encode(), key.encode())
		});
	}

	/// @notice Creates a `PalletInstance` junction with the given instance index.
	/// @param instance The index of the pallet instance to be represented in the junction.
	/// @return A `Junction` struct representing the pallet instance junction.
	function palletInstance(uint8 instance) internal pure returns (Junction memory) {
		return Junction({
			jType: JunctionType.PalletInstance,
			payload: abi.encodePacked(instance)
		});
	}

	/// @notice Encodes a `Junction` struct into a byte array suitable for SCALE encoding.
	/// @param junction The `Junction` struct to encode.
	/// @return A byte array representing the SCALE-encoded junction, including its type and payload.
	function encode(Junction memory junction) internal pure returns (bytes memory) {
		return abi.encodePacked(uint8(junction.jType), junction.payload);
	}

	/// @notice Decodes a byte array into a `Junction` struct, starting from the specified offset.
	/// @param data The byte array containing the SCALE-encoded junction data.
	/// @param offset The byte offset to start decoding from.
	/// @return junction A `Junction` struct representing the decoded junction, including its type and payload.
	/// @return bytesRead The total number of bytes read during decoding, including the type and payload.
	function decode(bytes memory data, uint256 offset) internal pure returns (Junction memory junction, uint256 bytesRead) {
		return decodeAt(data, 0);
	}

	/// @notice Decodes a byte array into a `Junction` struct, starting from the specified offset.
	/// @param data The byte array containing the SCALE-encoded junction data.
	/// @param offset The byte offset to start decoding from.
	/// @return junction A `Junction` struct representing the decoded junction, including its type and payload.
	/// @return bytesRead The total number of bytes read during decoding, including the type and payload.
	function decodeAt(bytes memory data, uint256 offset) internal pure returns (Junction memory junction, uint256 bytesRead) {
		if (offset >= data.length) revert InvalidJunctionLength();
		uint8 jType;
		assembly {
			jType := shr(248, mload(add(add(data, 32), offset)))
		}
		bytes memory payload = new bytes(data.length - offset - 1);
		for (uint256 i = 0; i < payload.length; i++) {
			payload[i] = data[offset + 1 + i];
		}
		junction = Junction({
			jType: JunctionType(jType),
			payload: payload
		});
		bytesRead = 1 + payload.length;
	}

	/// @notice Decodes a `Parachain` junction from a given `Junction` struct, extracting the parachain ID.
	/// @param junction The `Junction` struct to decode, which should represent a `Parachain` junction.
	/// @return parachainId The ID of the parachain extracted from the junction's payload.
	function decodeParachain(Junction memory junction) internal pure returns (uint32 parachainId) {
		if (junction.jType != JunctionType.Parachain) revert InvalidJunctionType(uint8(junction.jType));
		if (junction.payload.length != 4) revert InvalidJunctionPayload();
		assembly {
			parachainId := mload(add(junction.payload, 32))
		}
		return parachainId.fromLE();
	}

	/// @notice Decodes an `AccountId32` junction from a given `Junction` struct, extracting the network information and account ID.
	/// @param junction The `Junction` struct to decode, which should represent an `AccountId32` junction.
	/// @return params An `AccountId32Params` struct containing the decoded network information and account ID.
	function decodeAccountId32(Junction memory junction) internal pure returns (AccountId32Params memory params) {
		if (junction.jType != JunctionType.AccountId32) revert InvalidJunctionType(uint8(junction.jType));
		if (junction.payload.length != 33 && junction.payload.length != 34) revert InvalidJunctionPayload();
		bool hasNetwork = junction.payload[0] != 0;
		uint256 offset = 1;
		NetworkId network;
		if (hasNetwork) {
			(network, bytesRead) = NetworkId.decodeAt(junction.payload, offset);
			offset += bytesRead;
		}
		bytes32 id;
		assembly {
			id := mload(add(junction.payload, add(32, offset)))
		}
		id = id.fromLE();
		return AccountId32Params({
			hasNetwork: hasNetwork,
			network: network,
			id: id
		});
	}

	/// @notice Decodes an `AccountIndex64` junction from a given `Junction` struct, extracting the network information and account index.
	/// @param junction The `Junction` struct to decode, which should represent an `AccountIndex64` junction.
	/// @return params An `AccountIndex64Params` struct containing the decoded network information and account index.
	function decodeAccountIndex64(Junction memory junction) internal pure returns (AccountIndex64Params memory params) {
		if (junction.jType != JunctionType.AccountIndex64) revert InvalidJunctionType(uint8(junction.jType));
		if (junction.payload.length != 9 && junction.payload.length != 10) revert InvalidJunctionPayload();
		bool hasNetwork = junction.payload[0] != 0;
		uint256 offset = 1;
		NetworkId network;
		if (hasNetwork) {
			(network, bytesRead) = NetworkId.decodeAt(junction.payload, offset);
			offset += bytesRead;
		}
		uint64 index;
		assembly {
			index := mload(add(junction.payload, add(32, offset)))
		}
		index = index.fromLE();
		return AccountIndex64Params({
			hasNetwork: hasNetwork,
			network: network,
			index: index
		});
	}

	/// @notice Decodes an `AccountKey20` junction from a given `Junction` struct, extracting the network information and account key.
	/// @param junction The `Junction` struct to decode, which should represent an `AccountKey20` junction.
	/// @return params An `AccountKey20Params` struct containing the decoded network information and account key.
	function decodeAccountKey20(Junction memory junction) internal pure returns (AccountKey20Params memory params) {
		if (junction.jType != JunctionType.AccountKey20) revert InvalidJunctionType(uint8(junction.jType));
		if (junction.payload.length != 21 && junction.payload.length != 22) revert InvalidJunctionPayload();
		bool hasNetwork = junction.payload[0] != 0;
		uint256 offset = 1;
		NetworkId network;
		if (hasNetwork) {
			(network, bytesRead) = NetworkId.decodeAt(junction.payload, offset);
			offset += bytesRead;
		}
		address key;
		bytes memory keyBytes = new bytes(20);
		for (uint256 i = 0; i < 20; i++) {
			keyBytes[i] = junction.payload[offset + i];
		}
		key = keyBytes.toAddress();
		return AccountKey20Params({
			hasNetwork: hasNetwork,
			network: network,
			key: key
		});
	}

	/// @notice Decodes a `PalletInstance` junction from a given `Junction` struct, extracting the pallet instance index.
	/// @param junction The `Junction` struct to decode, which should represent a `PalletInstance` junction.
	/// @return instance The index of the pallet instance extracted from the junction's payload.
	function decodePalletInstance(Junction memory junction) internal pure returns (uint8 instance) {
		if (junction.jType != JunctionType.PalletInstance) revert InvalidJunctionType(uint8(junction.jType));
		if (junction.payload.length != 1) revert InvalidJunctionPayload();
		return uint8(junction.payload[0]);
	}
}