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

error InvalidJunctionPayload();

using Address for address;
using Bytes32 for bytes32;
using NetworkIdCodec for NetworkId;

// ============ Factory Functions ============

/// @notice Creates a `Parachain` junction with the given parachain ID.
/// @param parachainId The ID of the parachain to be represented in the junction.
/// @return A `Junction` struct representing the parachain junction.
function parachain(uint32 parachainId) pure returns (Junction memory) {
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
) pure returns (Junction memory) {
    return
        Junction({
            jType: JunctionType.AccountId32,
            payload: abi.encodePacked(hasNetwork, network.encode(), id.encode())
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
) pure returns (Junction memory) {
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
) pure returns (Junction memory) {
    return
        Junction({
            jType: JunctionType.AccountKey20,
            payload: abi.encodePacked(hasNetwork, network.encode(), key.encode())
        });
}

/// @notice Creates a `PalletInstance` junction with the given instance index.
/// @param instance The index of the pallet instance to be represented in the junction.
/// @return A `Junction` struct representing the pallet instance junction.
function palletInstance(uint8 instance) pure returns (Junction memory) {
    return
        Junction({
            jType: JunctionType.PalletInstance,
            payload: abi.encodePacked(instance)
        });
}

/// @notice Creates a `GeneralIndex` junction with the given index.
/// @param index The index to be represented in the junction.
/// @return A `Junction` struct representing the general index junction.
function generalIndex(uint128 index) pure returns (Junction memory) {
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
function generalKey(uint8 length, bytes32 key) pure returns (Junction memory) {
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
function onlyChild() pure returns (Junction memory) {
    return Junction({jType: JunctionType.OnlyChild, payload: ""});
}

/// @notice Creates a `Plurality` junction with the specified body ID and body part.
/// @param id The identifier for the body of the plurality, represented as a `BodyId` struct.
/// @param part The part of the body that is relevant for this junction, represented as a `BodyPart` struct.
/// @return A `Junction` struct representing the `Plurality` junction with the provided parameters.
function plurality(
    BodyId memory id,
    BodyPart memory part
) pure returns (Junction memory) {
    return
        Junction({
            jType: JunctionType.Plurality,
            payload: abi.encodePacked(BodyIdCodec.encode(id), BodyPartCodec.encode(part))
        });
}

/// @notice Creates a `GlobalConsensus` junction, which represents a global network capable of externalizing its own consensus.
/// @return A `Junction` struct representing the `GlobalConsensus` junction, with an empty payload.
function globalConsensus() pure returns (Junction memory) {
    return Junction({jType: JunctionType.GlobalConsensus, payload: ""});
}
