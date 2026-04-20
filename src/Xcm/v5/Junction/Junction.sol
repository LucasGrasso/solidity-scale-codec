// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BodyId} from "../BodyId/BodyId.sol";
import {BodyIdCodec} from "../BodyId/BodyIdCodec.sol";
import {BodyPart} from "../BodyPart/BodyPart.sol";
import {BodyPartCodec} from "../BodyPart/BodyPartCodec.sol";
import {NetworkId} from "../NetworkId/NetworkId.sol";
import {NetworkIdCodec} from "../NetworkId/NetworkIdCodec.sol";
import {Bytes32} from "../../../Scale/Bytes/Bytes32.sol";
import {Address} from "../../../Scale/Address/Address.sol";
import {Compact} from "../../../Scale/Compact/Compact.sol";

/// @dev Discriminant for the different types of junctions in XCM v5. Each variant corresponds to a specific structure of the payload.
enum JunctionVariant {
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

/// @notice Parameters for a `Parachain` junction.
struct ParachainParams {
    /// @custom:property The parachain identifier.
    uint32 parachainId;
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
    NetworkId network;
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    bool hasNetwork;
    /// @custom:property The 8-byte index identifier for the account.
    uint64 index;
}

/// @notice Parameters for an `AccountKey20` junction, containing optional network information and a 20-byte account key.
struct AccountKey20Params {
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    NetworkId network;
    /// @custom:property Indicates whether the junction includes network information. If true, the `network` field contains valid data; if false, the `network` field should be ignored.
    bool hasNetwork;
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

/// @notice Parameters for a `PalletInstance` junction.
struct PalletInstanceParams {
    /// @custom:property The pallet instance index.
    uint8 instance;
}

/// @notice Parameters for a `GeneralIndex` junction.
struct GeneralIndexParams {
    /// @custom:property The general compact index within context.
    uint128 index;
}

/// @notice Parameters for a `GlobalConsensus` junction.
struct GlobalConsensusParams {
    /// @custom:property The `NetworkId` associated with the global consensus, See `NetworkId` struct for details.
    NetworkId network;
}

/// @notice A single item in a path to describe the relative location of a consensus system. Each item assumes a pre-existing location as its context and is defined in terms of it.
struct Junction {
    /// @custom:property variant The type of the junction, determining how to interpret the payload. See `JunctionVariant` enum for possible values.
    JunctionVariant variant;
    /// @custom:property payload The SCALE-encoded data specific to the junction type. The structure of this data varies based on `variant`.
    bytes payload;
}

error InvalidJunctionPayload();

using Address for address;
using Bytes32 for bytes32;
using NetworkIdCodec for NetworkId;

// ============ Factory Functions ============

/// @notice Creates a `Parachain` junction with the given parachain ID.
/// @param params Parameters for the parachain variant.
/// @return A `Junction` struct representing the parachain junction.
function parachain(
    ParachainParams memory params
) pure returns (Junction memory) {
    return
        Junction({
            variant: JunctionVariant.Parachain,
            payload: Compact.encode(params.parachainId)
        });
}

/// @notice Creates an `AccountId32` junction with the specified parameters.
/// @param params Parameters for the account-id-32 variant.
/// @return A `Junction` struct representing the `AccountId32` junction with the provided parameters.
function accountId32(
    AccountId32Params memory params
) pure returns (Junction memory) {
    bytes memory payload = abi.encodePacked(params.hasNetwork);
    if (params.hasNetwork) {
        payload = abi.encodePacked(payload, params.network.encode());
    }
    payload = abi.encodePacked(payload, params.id);
    return Junction({variant: JunctionVariant.AccountId32, payload: payload});
}

/// @notice Creates an `AccountIndex64` junction with the specified parameters.
/// @param params Parameters for the account-index-64 variant.
/// @return A `Junction` struct representing the `AccountIndex64` junction with the provided parameters.
function accountIndex64(
    AccountIndex64Params memory params
) pure returns (Junction memory) {
    bytes memory payload = abi.encodePacked(params.hasNetwork);
    if (params.hasNetwork) {
        payload = abi.encodePacked(payload, params.network.encode());
    }
    payload = abi.encodePacked(payload, Compact.encode(params.index));
    return
        Junction({variant: JunctionVariant.AccountIndex64, payload: payload});
}

/// @notice Creates an `AccountKey20` junction with the specified parameters.
/// @param params Parameters for the account-key-20 variant.
/// @return A `Junction` struct representing the `AccountKey20` junction with the provided parameters.
function accountKey20(
    AccountKey20Params memory params
) pure returns (Junction memory) {
    bytes memory payload = abi.encodePacked(params.hasNetwork);
    if (params.hasNetwork) {
        payload = abi.encodePacked(payload, params.network.encode());
    }
    payload = abi.encodePacked(payload, params.key.encode());
    return Junction({variant: JunctionVariant.AccountKey20, payload: payload});
}

/// @notice Creates a `PalletInstance` junction with the given instance index.
/// @param params Parameters for the pallet-instance variant.
/// @return A `Junction` struct representing the pallet instance junction.
function palletInstance(
    PalletInstanceParams memory params
) pure returns (Junction memory) {
    return
        Junction({
            variant: JunctionVariant.PalletInstance,
            payload: abi.encodePacked(params.instance)
        });
}

/// @notice Creates a `GeneralIndex` junction with the given index.
/// @param params Parameters for the general-index variant.
/// @return A `Junction` struct representing the general index junction.
function generalIndex(
    GeneralIndexParams memory params
) pure returns (Junction memory) {
    return
        Junction({
            variant: JunctionVariant.GeneralIndex,
            payload: Compact.encode(params.index)
        });
}

/// @notice Creates a `GeneralKey` junction with the given key.
/// @param params Parameters for the general-key variant.
/// @return A `Junction` struct representing the general key junction with the provided parameters.
function generalKey(
    GeneralKeyParams memory params
) pure returns (Junction memory) {
    if (params.length == 0 || params.length > 32) {
        revert InvalidJunctionPayload();
    }
    return
        Junction({
            variant: JunctionVariant.GeneralKey,
            payload: abi.encodePacked(params.length, params.key)
        });
}

/// @notice Creates an `OnlyChild` junction, which represents the unambiguous child in the context.
/// @return A `Junction` struct representing the `OnlyChild` junction, with an empty payload.
function onlyChild() pure returns (Junction memory) {
    return Junction({variant: JunctionVariant.OnlyChild, payload: ""});
}

/// @notice Creates a `GlobalConsensus` junction, which represents a global network capable of externalizing its own consensus.
/// @param params Parameters for the global consensus variant.
/// @return A `Junction` struct representing the `GlobalConsensus` junction, with the encoded network payload.
function globalConsensus(
    GlobalConsensusParams memory params
) pure returns (Junction memory) {
    return
        Junction({
            variant: JunctionVariant.GlobalConsensus,
            payload: params.network.encode()
        });
}

/// @notice Creates a `Plurality` junction with the specified body ID and body part.
/// @param params Parameters for the plurality variant.
/// @return A `Junction` struct representing the `Plurality` junction with the provided parameters.
function plurality(
    PluralityParams memory params
) pure returns (Junction memory) {
    return
        Junction({
            variant: JunctionVariant.Plurality,
            payload: abi.encodePacked(
                BodyIdCodec.encode(params.id),
                BodyPartCodec.encode(params.part)
            )
        });
}

/// @notice Creates a `GlobalConsensus` junction, which represents a global network capable of externalizing its own consensus.
/// @return A `Junction` struct representing the `GlobalConsensus` junction, with an empty payload.
function globalConsensus() pure returns (Junction memory) {
    return Junction({variant: JunctionVariant.GlobalConsensus, payload: ""});
}
