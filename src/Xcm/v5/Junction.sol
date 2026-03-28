// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BodyIdCodec, BodyId} from "./BodyId.sol";
import {BodyPartCodec, BodyPart} from "./BodyPart.sol";
import {NetworkIdCodec, NetworkId} from "./NetworkId.sol";
import {Bytes32} from "../../Scale/Bytes.sol";
import {Address} from "../../Scale/Address.sol";
import {Compact} from "../../Scale/Compact.sol";

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
    /// @custom:variant A non-descript index within the context location. NOTE: Try to avoid using this and instead use a more specific item.
    GeneralIndex,
    /// @custom:variant A nondescript array datum, 32 bytes, acting as a key within the context location. NOTE: Try to avoid using this and instead use a more specific item.
    GeneralKey,
    /// @custom:variant The unambiguous child. Not currently used except as a fallback when deriving context.
    OnlyChild,
    /// @custom:variant A pluralistic body existing within consensus.
    Plurality,
    /// @custom:variant A global network capable of externalizing its own consensus. This is not generally meaningful outside of the universal level.
    GlobalConsensus
}

/// @notice Parameters for an `AccountId32` junction, containing optional network information and a 32-byte account identifier.
struct AccountId32Params {
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    bool hasNetwork;
    /// @custom:property The `NetworkId` associated with the account, See `NetworkId` struct for details. This field is only meaningful if `hasNetwork` is true.
    NetworkId network;
    /// @custom:property The 32-byte identifier for the account.
    bytes32 id;
}

/// @notice Parameters for an `Plurality` junction
struct PluralityParams {
    /// @custom:property The identifier for the body of the plurality. See `BodyId` enum for details.
    BodyId id;
    /// @custom:property The part of the body that is relevant for this junction. See `BodyPart` struct for details.
    BodyPart part;
}

/// @notice Parameters for an `AccountIndex64` junction, containing optional network information and a 64-bit account index.
struct AccountIndex64Params {
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    bool hasNetwork;
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    NetworkId network;
    /// @custom:property The 8-byte index identifier for the account.
    uint64 index;
}

/// @notice Parameters for an `AccountKey20` junction, containing optional network information and a 20-byte account key.
struct AccountKey20Params {
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    bool hasNetwork;
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    NetworkId network;
    /// @custom:property The 20-byte key identifier for the account, represented as an `address` in Solidity.
    address key;
}

/// @notice Parameters for an `GeneralKey` junction
struct GeneralKeyParams {
    /// @custom:property The length of the byte array acting as a key within the context location. This should be between 1 and 32, inclusive, to ensure valid encoding and decoding.
    uint8 length;
    /// @custom:property The byte array acting as a key within the context location.
    bytes32 key;
}

/// @notice A single item in a path to describe the relative location of a consensus system. Each item assumes a pre-existing location as its context and is defined in terms of it.
struct Junction {
    /// @custom:property jType The type of the junction, determining how to interpret the payload. See `JunctionType` enum for possible values.
    JunctionType jType;
    /// @custom:property payload The SCALE-encoded data specific to the junction type. The structure of this data varies based on `jType`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `Junction`
/// @notice SCALE-compliant encoder/decoder for the `Junction` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library JunctionCodec {
    error InvalidJunctionLength();
    error InvalidJunctionType(uint8 jType);
    error InvalidJunctionPayload();

    using Address for address;
    using Bytes32 for bytes32;
    using NetworkIdCodec for NetworkId;

    /// @notice Creates a `Parachain` junction with the given parachain ID.
    /// @param parachainId The ID of the parachain to be represented in the junction.
    /// @return A `Junction` struct representing the parachain junction.
    function parachain(
        uint32 parachainId
    ) internal pure returns (Junction memory) {
        return
            Junction({
                jType: JunctionType.Parachain,
                payload: Compact.encode(parachainId)
            });
    }

    /// @notice Creates an `AccountId32` junction with the specified parameters.
    /// @param hasNetwork A boolean indicating whether the junction includes network information.
    /// @param network The `NetworkId` associated with the account, if `hasNetwork` is true.
    /// @param id The 32-byte identifier for the account.
    /// @return A `Junction` struct representing the `AccountId32` junction with the provided parameters.
    function accountId32(
        bool hasNetwork,
        NetworkId memory network,
        bytes32 id
    ) internal pure returns (Junction memory) {
        return
            Junction({
                jType: JunctionType.AccountId32,
                payload: abi.encodePacked(
                    hasNetwork,
                    network.encode(),
                    id.encode()
                )
            });
    }

    /// @notice Creates an `AccountIndex64` junction with the specified parameters.
    /// @param hasNetwork A boolean indicating whether the junction includes network information.
    /// @param network The `NetworkId` associated with the account, if `hasNetwork` is true.
    /// @param index The 64-bit index identifier for the account.
    /// @return A `Junction` struct representing the `AccountIndex64` junction with the provided parameters.
    function accountIndex64(
        bool hasNetwork,
        NetworkId memory network,
        uint64 index
    ) internal pure returns (Junction memory) {
        return
            Junction({
                jType: JunctionType.AccountIndex64,
                payload: abi.encodePacked(
                    hasNetwork,
                    network.encode(),
                    Compact.encode(index)
                )
            });
    }

    /// @notice Creates an `AccountKey20` junction with the specified parameters.
    /// @param hasNetwork A boolean indicating whether the junction includes network information.
    /// @param network The `NetworkId` associated with the account, if `hasNetwork` is true.
    /// @param key The 20-byte key identifier for the account, represented as an `address` in Solidity.
    /// @return A `Junction` struct representing the `AccountKey20` junction with the provided parameters.
    function accountKey20(
        bool hasNetwork,
        NetworkId memory network,
        address key
    ) internal pure returns (Junction memory) {
        return
            Junction({
                jType: JunctionType.AccountKey20,
                payload: abi.encodePacked(
                    hasNetwork,
                    network.encode(),
                    key.encode()
                )
            });
    }

    /// @notice Creates a `PalletInstance` junction with the given instance index.
    /// @param instance The index of the pallet instance to be represented in the junction.
    /// @return A `Junction` struct representing the pallet instance junction.
    function palletInstance(
        uint8 instance
    ) internal pure returns (Junction memory) {
        return
            Junction({
                jType: JunctionType.PalletInstance,
                payload: abi.encodePacked(instance)
            });
    }

    /// @notice Creates a `GeneralIndex` junction with the given index.
    /// @param index The index to be represented in the junction.
    /// @return A `Junction` struct representing the general index junction.
    function generalIndex(
        uint128 index
    ) internal pure returns (Junction memory) {
        return
            Junction({
                jType: JunctionType.GeneralIndex,
                payload: Compact.encode(index)
            });
    }

    /// @notice Creates a `GeneralKey` junction with the given key.
    /// @param length The byte array acting as a key within the context location. This should be between 1 and 32 bytes in length.
    /// @param key The byte array acting as a key within the context location, represented as a `bytes32` in Solidity. Only the first `length` bytes will be used.
    /// @return A `Junction` struct representing the general key junction with the provided parameters.
    function generalKey(
        uint8 length,
        bytes32 key
    ) internal pure returns (Junction memory) {
        if (length == 0 || length > 32 || key.length != length)
            revert InvalidJunctionPayload();
        return
            Junction({
                jType: JunctionType.GeneralKey,
                payload: abi.encodePacked(length, key)
            });
    }

    /// @notice Creates an `OnlyChild` junction, which represents the unambiguous child in the context.
    /// @return A `Junction` struct representing the `OnlyChild` junction, with an empty payload.
    function onlyChild() internal pure returns (Junction memory) {
        return Junction({jType: JunctionType.OnlyChild, payload: ""});
    }

    /// @notice Creates a `Plurality` junction with the specified body ID and body part.
    /// @param id The identifier for the body of the plurality, represented as a `BodyId` struct.
    /// @param part The part of the body that is relevant for this junction, represented as a `BodyPart` struct.
    /// @return A `Junction` struct representing the `Plurality` junction with the provided parameters.
    function plurality(
        BodyId id,
        BodyPart part
    ) internal pure returns (Junction memory) {
        return
            Junction({
                jType: JunctionType.Plurality,
                payload: abi.encodePacked(
                    BodyIdCodec.encode(id),
                    BodyPartCodec.encode(part)
                )
            });
    }

    /// @notice Creates a `GlobalConsensus` junction, which represents a global network capable of externalizing its own consensus.
    /// @return A `Junction` struct representing the `GlobalConsensus` junction, with an empty payload.
    function globalConsensus() internal pure returns (Junction memory) {
        return Junction({jType: JunctionType.GlobalConsensus, payload: ""});
    }

    /// @notice Encodes a `Junction` struct into a byte array suitable for SCALE encoding.
    /// @param junction The `Junction` struct to encode.
    /// @return A byte array representing the SCALE-encoded junction, including its type and payload.
    function encode(
        Junction memory junction
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(junction.jType), junction.payload);
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
        bytes memory payload = new bytes(data.length - offset - 1);
        for (uint256 i = 0; i < payload.length; i++) {
            payload[i] = data[offset + 1 + i];
        }
        junction = Junction({jType: JunctionType(jType), payload: payload});
        bytesRead = 1 + payload.length;
    }

    /// @notice Decodes a `Parachain` junction from a given `Junction` struct, extracting the parachain ID.
    /// @param junction The `Junction` struct to decode, which should represent a `Parachain` junction.
    /// @return parachainId The ID of the parachain extracted from the junction's payload.
    function decodeParachain(
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
    function decodeAccountId32(
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
    function decodeAccountIndex64(
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
    function decodeAccountKey20(
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
    function decodePalletInstance(
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
    function decodeGeneralIndex(
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
    function decodeGeneralKey(
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
    function decodePlurality(
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
    function decodeGlobalConsensus(
        Junction memory junction
    ) internal pure returns (NetworkId memory networkId) {
        if (junction.jType != JunctionType.GlobalConsensus)
            revert InvalidJunctionType(uint8(junction.jType));
        (networkId, ) = NetworkIdCodec.decode(junction.payload);
    }
}
