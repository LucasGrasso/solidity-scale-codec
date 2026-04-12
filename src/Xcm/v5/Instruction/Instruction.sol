// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Asset} from "../Asset/Asset.sol";
import {AssetFilter} from "../AssetFilter/AssetFilter.sol";
import {Assets} from "../Assets/Assets.sol";
import {AssetTransferFilter} from "../AssetTransferFilter/AssetTransferFilter.sol";
import {Hint} from "../Hint/Hint.sol";
import {Junction} from "../Junction/Junction.sol";
import {Junctions} from "../Junctions/Junctions.sol";
import {Location} from "../Location/Location.sol";
import {NetworkId} from "../NetworkId/NetworkId.sol";
import {OriginKind} from "../OriginKind/OriginKind.sol";
import {QueryResponseInfo} from "../QueryResponseInfo/QueryResponseInfo.sol";
import {Response} from "../Response/Response.sol";
import {Weight} from "../Weight/Weight.sol";
import {WeightLimit} from "../WeightLimit/WeightLimit.sol";
import {XcmError} from "../XcmError/XcmError.sol";
import {QueryId} from "../Types/QueryId.sol";
import {MaybeErrorCode} from "../../v3/MaybeErrorCode/MaybeErrorCode.sol";
import {AssetsCodec} from "../Assets/AssetsCodec.sol";
import {AssetCodec} from "../Asset/AssetCodec.sol";
import {LocationCodec} from "../Location/LocationCodec.sol";
import {JunctionsCodec} from "../Junctions/JunctionsCodec.sol";
import {JunctionCodec} from "../Junction/JunctionCodec.sol";
import {AssetFilterCodec} from "../AssetFilter/AssetFilterCodec.sol";
import {AssetTransferFilterCodec} from "../AssetTransferFilter/AssetTransferFilterCodec.sol";
import {QueryResponseInfoCodec} from "../QueryResponseInfo/QueryResponseInfoCodec.sol";
import {ResponseCodec} from "../Response/ResponseCodec.sol";
import {XcmErrorCodec} from "../XcmError/XcmErrorCodec.sol";
import {NetworkIdCodec} from "../NetworkId/NetworkIdCodec.sol";
import {OriginKindCodec} from "../OriginKind/OriginKindCodec.sol";
import {WeightCodec} from "../Weight/WeightCodec.sol";
import {WeightLimitCodec} from "../WeightLimit/WeightLimitCodec.sol";
import {HintCodec} from "../Hint/HintCodec.sol";
import {MaybeErrorCodeCodec} from "../../v3/MaybeErrorCode/MaybeErrorCodeCodec.sol";

import {MAX_ASSET_TRANSFER_FILTERS, HINT_NUM_VARIANTS} from "../Constants.sol";

import {Compact} from "../../../Scale/Compact.sol";
import {Bool} from "../../../Scale/Bool/Bool.sol";
import {Bytes32} from "../../../Scale/Bytes/Bytes32.sol";
import {Bytes} from "../../../Scale/Bytes/Bytes.sol";

/// @notice An error indicating that an instruction was invalid in some way, such as having malformed parameters or parameters that violate expected bounds.
error InvalidInstruction();

/// @notice Discriminant for the `Instruction` enum, representing the type of instruction being executed.
enum InstructionVariant {
    /// @custom:variant Withdraw asset(s) from the ownership of `origin` and place them into the Holding Register.
    WithdrawAsset,
    /// @custom:variant Asset(s) have been received into the ownership of this system on the `origin` system and equivalent derivatives should be placed into the Holding Register.
    ReserveAssetDeposited,
    /// @custom:variant Asset(s) have been destroyed on the `origin` system and equivalent assets should be created and placed into the Holding Register.
    ReceiveTeleportedAsset,
    /// @custom:variant Respond with information that the local system is expecting.
    QueryResponse,
    /// @custom:variant Withdraw asset(s) from the ownership of `origin` and place equivalent assets under the ownership of `beneficiary`.
    TransferAsset,
    /// @custom:variant Withdraw asset(s) from the ownership of `origin` and place equivalent assets under the ownership of `dest` within this consensus system.
    TransferReserveAsset,
    /// @custom:variant Apply the encoded transaction `call`, whose dispatch-origin should be `origin` as expressed by the kind of origin `origin_kind`.
    Transact,
    /// @custom:variant A message to notify about a new incoming HRMP channel.
    HrmpNewChannelOpenRequest,
    /// @custom:variant A message to notify about that a previously sent open channel request has been accepted by the recipient.
    HrmpChannelAccepted,
    /// @custom:variant A message to notify that the other party in an open channel decided to close it.
    HrmpChannelClosing,
    /// @custom:variant Clear the origin.
    ClearOrigin,
    /// @custom:variant Mutate the origin to some interior location.
    DescendOrigin,
    /// @custom:variant Immediately report the contents of the Error Register to the given destination via XCM.
    ReportError,
    /// @custom:variant Remove the asset(s) from the Holding Register and place equivalent assets under the ownership of `beneficiary`.
    DepositAsset,
    /// @custom:variant Remove the asset(s) from the Holding Register and place equivalent assets under the ownership of `dest`, then send a `ReserveAssetDeposited` onward message.
    DepositReserveAsset,
    /// @custom:variant Remove the asset(s) from the Holding Register and replace them with alternative assets.
    ExchangeAsset,
    /// @custom:variant Remove the asset(s) from holding and send a `WithdrawAsset` XCM message to a reserve location.
    InitiateReserveWithdraw,
    /// @custom:variant Remove the asset(s) from holding and send a `ReceiveTeleportedAsset` XCM message to a `dest` location.
    InitiateTeleport,
    /// @custom:variant Report to a given destination the contents of the Holding Register.
    ReportHolding,
    /// @custom:variant Pay for the execution of some XCM with up to `weight` picoseconds of execution time, paying with up to `fees` from the Holding Register.
    BuyExecution,
    /// @custom:variant Refund any surplus weight previously bought with `BuyExecution`.
    RefundSurplus,
    /// @custom:variant Set the Error Handler Register to code that should be called in the case of an error.
    SetErrorHandler,
    /// @custom:variant Set the Appendix Register to code that should be called after execution (including error handler) is finished.
    SetAppendix,
    /// @custom:variant Clear the Error Register.
    ClearError,
    /// @custom:variant Create some assets which are being held on behalf of the origin.
    ClaimAsset,
    /// @custom:variant Always throws an error of type `Trap`.
    Trap,
    /// @custom:variant Ask the destination system to respond with the most recent version of XCM that they support.
    SubscribeVersion,
    /// @custom:variant Cancel the effect of a previous `SubscribeVersion` instruction.
    UnsubscribeVersion,
    /// @custom:variant Reduce Holding by up to the given assets.
    BurnAsset,
    /// @custom:variant Throw an error if Holding does not contain at least the given assets.
    ExpectAsset,
    /// @custom:variant Ensure that the Origin Register equals some given value and throw an error if not.
    ExpectOrigin,
    /// @custom:variant Ensure that the Error Register equals some given value and throw an error if not.
    ExpectError,
    /// @custom:variant Ensure that the Transact Status Register equals some given value and throw an error if not.
    ExpectTransactStatus,
    /// @custom:variant Query the existence of a particular pallet type.
    QueryPallet,
    /// @custom:variant Ensure that a particular pallet with a particular version exists.
    ExpectPallet,
    /// @custom:variant Send a `QueryResponse` message containing the value of the Transact Status Register to some destination.
    ReportTransactStatus,
    /// @custom:variant Set the Transact Status Register to its default, cleared, value.
    ClearTransactStatus,
    /// @custom:variant Set the Origin Register to be some child of the Universal Ancestor.
    UniversalOrigin,
    /// @custom:variant Send a message on to Non-Local Consensus system.
    ExportMessage,
    /// @custom:variant Lock the locally held asset and prevent further transfer or withdrawal.
    LockAsset,
    /// @custom:variant Remove the lock over `asset` on this chain and allow the asset to be transferred.
    UnlockAsset,
    /// @custom:variant Asset has been locked on the `origin` system and may not be transferred.
    NoteUnlockable,
    /// @custom:variant Send an `UnlockAsset` instruction to the `locker` for the given `asset`.
    RequestUnlock,
    /// @custom:variant Sets the Fees Mode Register.
    SetFeesMode,
    /// @custom:variant Set the Topic Register.
    SetTopic,
    /// @custom:variant Clear the Topic Register.
    ClearTopic,
    /// @custom:variant Alter the current Origin to another given origin.
    AliasOrigin,
    /// @custom:variant A directive to indicate that the origin expects free execution of the message.
    UnpaidExecution,
    /// @custom:variant Takes an asset, uses it to pay for execution and puts the rest in the fees register. Successor to `BuyExecution`.
    PayFees,
    /// @custom:variant Initiates cross-chain transfer of assets in the holding register using specified asset transfer filters.
    InitiateTransfer,
    /// @custom:variant Executes inner `xcm` with origin set to the provided `descendant_origin`, then restores the original origin.
    ExecuteWithOrigin,
    /// @custom:variant Set hints for XCM execution, changing the behaviour of the XCM program.
    SetHints
}

/// @notice Params for `WithdrawAsset`.
struct WithdrawAssetParams {
    /// @custom:property The asset(s) to be withdrawn into holding.
    Assets assets;
}

/// @notice Params for `ReserveAssetDeposited`.
struct ReserveAssetDepositedParams {
    /// @custom:property The asset(s) that are minted into holding.
    Assets assets;
}

/// @notice Params for `ReceiveTeleportedAsset`.
struct ReceiveTeleportedAssetParams {
    /// @custom:property The asset(s) minted into the Holding Register.
    Assets assets;
}

/// @notice Params for `QueryResponse`.
struct QueryResponseParams {
    /// @custom:property The identifier of the query that resulted in this response.
    QueryId queryId;
    /// @custom:property The message content.
    Response response;
    /// @custom:property The maximum weight that handling this response should take.
    Weight maxWeight;
    /// @custom:property Whether `querier` is present.
    bool hasQuerier;
    /// @custom:property The location responsible for initiating the response, when present.
    Location querier;
}

/// @notice Params for `TransferAsset`.
struct TransferAssetParams {
    /// @custom:property The asset(s) to be withdrawn.
    Assets assets;
    /// @custom:property The new owner for the assets.
    Location beneficiary;
}

/// @notice Params for `TransferReserveAsset`.
struct TransferReserveAssetParams {
    /// @custom:property The asset(s) to be withdrawn.
    Assets assets;
    /// @custom:property The location whose sovereign account will own the assets.
    Location dest;
    /// @custom:property Instructions that follow `ReserveAssetDeposited`. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `Transact`.
struct TransactParams {
    /// @custom:property The means of expressing message origin as dispatch origin.
    OriginKind originKind;
    /// @custom:property Whether `fallbackMaxWeight` is present.
    bool hasFallbackMaxWeight;
    /// @custom:property Compatibility fallback weight, corresponding to v4 `require_weight_at_most`.
    Weight fallbackMaxWeight;
    /// @custom:property The raw encoded call bytes (`DoubleEncoded<Call>.encoded`, equivalent to Rust `Vec<u8>`). The `Transact` factory SCALE-encodes this as `Vec<u8>` (Compact length + bytes).
    bytes call;
}

/// @notice Params for `HrmpNewChannelOpenRequest`.
struct HrmpNewChannelOpenRequestParams {
    /// @custom:property The sender in the to-be-opened channel.
    uint32 sender;
    /// @custom:property The maximum size of a message proposed by the sender.
    uint32 maxMessageSize;
    /// @custom:property The maximum number of messages that can be queued in the channel.
    uint32 maxCapacity;
}

/// @notice Params for `HrmpChannelAccepted`.
struct HrmpChannelAcceptedParams {
    /// @custom:property The recipient whose open-channel request was accepted.
    uint32 recipient;
}

/// @notice Params for `HrmpChannelClosing`.
struct HrmpChannelClosingParams {
    /// @custom:property The party initiating the channel closure.
    uint32 initiator;
    /// @custom:property The channel sender.
    uint32 sender;
    /// @custom:property The channel recipient.
    uint32 recipient;
}

/// @notice Params for `DescendOrigin`.
struct DescendOriginParams {
    /// @custom:property Interior location to descend origin into.
    Junctions interior;
}

/// @notice Params for `ReportError`.
struct ReportErrorParams {
    /// @custom:property Information for constructing and sending the query response.
    QueryResponseInfo responseInfo;
}

/// @notice Params for `DepositAsset`.
struct DepositAssetParams {
    /// @custom:property Asset filter selecting assets removed from holding.
    AssetFilter assets;
    /// @custom:property The new owner for the assets.
    Location beneficiary;
}

/// @notice Params for `DepositReserveAsset`.
struct DepositReserveAssetParams {
    /// @custom:property Asset filter selecting assets removed from holding.
    AssetFilter assets;
    /// @custom:property The location whose sovereign account will own the assets.
    Location dest;
    /// @custom:property Orders that follow `ReserveAssetDeposited`. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `ExchangeAsset`.
struct ExchangeAssetParams {
    /// @custom:property Maximum assets to remove from holding.
    AssetFilter give;
    /// @custom:property Minimum assets expected in exchange.
    Assets want;
    /// @custom:property If true, prefer maximal exchange up to `give`; otherwise minimal exchange satisfying `want`.
    bool maximal;
}

/// @notice Params for `InitiateReserveWithdraw`.
struct InitiateReserveWithdrawParams {
    /// @custom:property Asset filter selecting assets removed from holding.
    AssetFilter assets;
    /// @custom:property Reserve location for all selected assets.
    Location reserve;
    /// @custom:property Instructions to execute once withdrawn on reserve. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `InitiateTeleport`.
struct InitiateTeleportParams {
    /// @custom:property Asset filter selecting assets removed from holding.
    AssetFilter assets;
    /// @custom:property Destination location that accepts teleports from this origin.
    Location dest;
    /// @custom:property Instructions to execute on destination. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `ReportHolding`.
struct ReportHoldingParams {
    /// @custom:property Information for constructing and sending the query response.
    QueryResponseInfo responseInfo;
    /// @custom:property Filter over holdings to be reported.
    AssetFilter assets;
}

/// @notice Params for `BuyExecution`.
struct BuyExecutionParams {
    /// @custom:property The asset(s) used to pay fees.
    Asset fees;
    /// @custom:property The maximum amount of weight to purchase.
    WeightLimit weightLimit;
}

/// @notice Params for `SetErrorHandler`.
struct SetErrorHandlerParams {
    /// @custom:property Error handler code. SCALE-encoded Xcm<Call>.
    bytes xcm;
}

/// @notice Params for `SetAppendix`.
struct SetAppendixParams {
    /// @custom:property Appendix code executed after program completion. SCALE-encoded Xcm<Call>.
    bytes xcm;
}

/// @notice Params for `ClaimAsset`.
struct ClaimAssetParams {
    /// @custom:property Assets to claim; must exactly match claimable assets for ticket origin.
    Assets assets;
    /// @custom:property Ticket identifier used to locate the claimable asset.
    Location ticket;
}

/// @notice Params for `Trap`.
struct TrapParams {
    /// @custom:property Trap code used as the inner value of the `Trap` error.
    uint64 code;
}

/// @notice Params for `SubscribeVersion`.
struct SubscribeVersionParams {
    /// @custom:property Query identifier replicated into the response message.
    QueryId queryId;
    /// @custom:property Maximum weight allowed for the responding `QueryResponse` execution.
    Weight maxResponseWeight;
}

/// @notice Params for `BurnAsset`.
struct BurnAssetParams {
    /// @custom:property Assets to burn from holding up to the provided amount.
    Assets assets;
}

/// @notice Params for `ExpectAsset`.
struct ExpectAssetParams {
    /// @custom:property Assets that must be present in holding.
    Assets assets;
}

/// @notice Params for `ExpectOrigin`.
struct ExpectOriginParams {
    /// @custom:property Whether an expected origin is provided.
    bool hasOrigin;
    /// @custom:property Expected origin location when `hasOrigin` is true.
    Location origin;
}

/// @notice Params for `ExpectError`.
struct ExpectErrorParams {
    /// @custom:property Whether an expected error tuple is provided.
    bool hasError;
    /// @custom:property Expected instruction index when `hasError` is true.
    uint32 index;
    /// @custom:property Expected XCM error when `hasError` is true.
    XcmError err;
}

/// @notice Params for `ExpectTransactStatus`.
struct ExpectTransactStatusParams {
    /// @custom:property Expected transact status register value.
    MaybeErrorCode transactStatus;
}

/// @notice Params for `QueryPallet`.
struct QueryPalletParams {
    /// @custom:property Pallet module name to query.
    bytes moduleName;
    /// @custom:property Information for constructing and sending the query response.
    QueryResponseInfo responseInfo;
}

/// @notice Params for `ExpectPallet`.
struct ExpectPalletParams {
    /// @custom:property Expected pallet index.
    uint32 index;
    /// @custom:property Expected pallet name.
    bytes name;
    /// @custom:property Expected pallet module name.
    bytes moduleName;
    /// @custom:property Expected crate major version.
    uint32 crateMajor;
    /// @custom:property Minimum acceptable crate minor version.
    uint32 minCrateMinor;
}

/// @notice Params for `ReportTransactStatus`.
struct ReportTransactStatusParams {
    /// @custom:property Information for constructing and sending the query response.
    QueryResponseInfo responseInfo;
}

/// @notice Params for `UniversalOrigin`.
struct UniversalOriginParams {
    /// @custom:property Child junction of the Universal Ancestor to set as origin.
    Junction junction;
}

/// @notice Params for `ExportMessage`.
struct ExportMessageParams {
    /// @custom:property Remote consensus system to export to.
    NetworkId network;
    /// @custom:property Destination interior location relative to the remote consensus system.
    Junctions destination;
    /// @custom:property Message to export. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `LockAsset`.
struct LockAssetParams {
    /// @custom:property Asset to lock.
    Asset asset;
    /// @custom:property Origin required to unlock via a corresponding `UnlockAsset`.
    Location unlocker;
}

/// @notice Params for `UnlockAsset`.
struct UnlockAssetParams {
    /// @custom:property Asset to unlock.
    Asset asset;
    /// @custom:property Asset owner on the local chain.
    Location target;
}

/// @notice Params for `NoteUnlockable`.
struct NoteUnlockableParams {
    /// @custom:property Asset that is now unlockable from this origin.
    Asset asset;
    /// @custom:property Owner of the asset on the chain where it was locked.
    Location owner;
}

/// @notice Params for `RequestUnlock`.
struct RequestUnlockParams {
    /// @custom:property Asset requested for unlock.
    Asset asset;
    /// @custom:property Location of the locker from prior `NoteUnlockable`.
    Location locker;
}

/// @notice Params for `SetFeesMode`.
struct SetFeesModeParams {
    /// @custom:property If true, fees are withdrawn just-in-time for instructions.
    bool jitWithdraw;
}

/// @notice Params for `SetTopic`.
struct SetTopicParams {
    /// @custom:property 32-byte topic identifier.
    bytes32 topic;
}

/// @notice Params for `AliasOrigin`.
struct AliasOriginParams {
    /// @custom:property New origin to alias to.
    Location location;
}

/// @notice Params for `UnpaidExecution`.
struct UnpaidExecutionParams {
    /// @custom:property Free-execution weight limit.
    WeightLimit weightLimit;
    /// @custom:property Whether a specific origin check is required.
    bool hasCheckOrigin;
    /// @custom:property Expected origin when `hasCheckOrigin` is true.
    Location checkOrigin;
}

/// @notice Params for `PayFees`.
struct PayFeesParams {
    /// @custom:property Asset used to pay execution fees.
    Asset asset;
}

/// @notice Params for `InitiateTransfer`.
struct InitiateTransferParams {
    /// @custom:property Location of the program next hop.
    Location destination;
    /// @custom:property Whether `remoteFees` is provided.
    bool hasRemoteFees;
    /// @custom:property Optional fee-reserved transfer filter used first on remote side.
    AssetTransferFilter remoteFees;
    /// @custom:property Whether to preserve origin (`AliasOrigin`) instead of clearing it.
    bool preserveOrigin;
    /// @custom:property Transfer filters matched against holding assets for this leg.
    AssetTransferFilter[] assets;
    /// @custom:property Custom instructions to run on destination. SCALE-encoded Xcm<()>.
    bytes remoteXcm;
}

/// @notice Params for `ExecuteWithOrigin`.
struct ExecuteWithOriginParams {
    /// @custom:property Whether `descendantOrigin` is provided.
    bool hasDescendantOrigin;
    /// @custom:property Optional descendant origin for executing inner XCM.
    Junctions descendantOrigin;
    /// @custom:property Inner instructions executed under the derived origin. SCALE-encoded Xcm<Call>.
    bytes xcm;
}

/// @notice Params for `SetHints`.
struct SetHintsParams {
    /// @custom:property A bounded vector of execution hints.
    Hint[] hints;
}

/// @notice Cross-Consensus Message: A message from one consensus system to another.
/// @dev This is the inner XCM format and is version-sensitive. Messages are typically passed using the outer XCM format, known as `VersionedXcm`.
struct Instruction {
    /// @custom:property The type of the instruction. See `InstructionVariant` enum for possible values.
    InstructionVariant variant;
    /// @custom:property SCALE-encoded instruction parameters. The type of the parameters depends on the instruction type; see the corresponding `Params` struct for each variant.
    bytes payload;
}

// ============ Factory Functions ============

/// @notice Creates an `Instruction` struct representing the `WithdrawAsset` variant with the provided `params`.
function withdrawAsset(
    WithdrawAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.WithdrawAsset,
            payload: AssetsCodec.encode(params.assets)
        });
}

/// @notice Creates an `Instruction` struct representing the `ReserveAssetDeposited` variant with the provided `params`.
function reserveAssetDeposited(
    ReserveAssetDepositedParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ReserveAssetDeposited,
            payload: AssetsCodec.encode(params.assets)
        });
}

/// @notice Creates an `Instruction` struct representing the `ReceiveTeleportedAsset` variant with the provided `params`.
function receiveTeleportedAsset(
    ReceiveTeleportedAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ReceiveTeleportedAsset,
            payload: AssetsCodec.encode(params.assets)
        });
}

/// @notice Creates an `Instruction` struct representing the `QueryResponse` variant with the provided `params`.
function queryResponse(
    QueryResponseParams memory params
) pure returns (Instruction memory) {
    bytes memory payload = abi.encodePacked(
        Compact.encode(uint256(QueryId.unwrap(params.queryId))),
        ResponseCodec.encode(params.response),
        WeightCodec.encode(params.maxWeight),
        Bool.encode(params.hasQuerier)
    );
    if (params.hasQuerier) {
        payload = abi.encodePacked(
            payload,
            LocationCodec.encode(params.querier)
        );
    }
    return
        Instruction({
            variant: InstructionVariant.QueryResponse,
            payload: payload
        });
}

/// @notice Creates an `Instruction` struct representing the `TransferAsset` variant with the provided `params`.
function transferAsset(
    TransferAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.TransferAsset,
            payload: abi.encodePacked(
                AssetsCodec.encode(params.assets),
                LocationCodec.encode(params.beneficiary)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `TransferReserveAsset` variant with the provided `params`.
function transferReserveAsset(
    TransferReserveAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.TransferReserveAsset,
            payload: abi.encodePacked(
                AssetsCodec.encode(params.assets),
                LocationCodec.encode(params.dest),
                params.xcm
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `Transact` variant with the provided `params`.
function transact(
    TransactParams memory params
) pure returns (Instruction memory) {
    bytes memory payload = abi.encodePacked(
        OriginKindCodec.encode(params.originKind),
        Bool.encode(params.hasFallbackMaxWeight)
    );
    if (params.hasFallbackMaxWeight) {
        payload = abi.encodePacked(
            payload,
            WeightCodec.encode(params.fallbackMaxWeight)
        );
    }
    payload = abi.encodePacked(payload, Bytes.encode(params.call));
    return
        Instruction({variant: InstructionVariant.Transact, payload: payload});
}

/// @notice Creates an `Instruction` struct representing the `HrmpNewChannelOpenRequest` variant with the provided `params`.
function hrmpNewChannelOpenRequest(
    HrmpNewChannelOpenRequestParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.HrmpNewChannelOpenRequest,
            payload: abi.encodePacked(
                Compact.encode(params.sender),
                Compact.encode(params.maxMessageSize),
                Compact.encode(params.maxCapacity)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `HrmpChannelAccepted` variant with the provided `params`.
function hrmpChannelAccepted(
    HrmpChannelAcceptedParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.HrmpChannelAccepted,
            payload: Compact.encode(params.recipient)
        });
}

/// @notice Creates an `Instruction` struct representing the `HrmpChannelClosing` variant with the provided `params`.
function hrmpChannelClosing(
    HrmpChannelClosingParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.HrmpChannelClosing,
            payload: abi.encodePacked(
                Compact.encode(params.initiator),
                Compact.encode(params.sender),
                Compact.encode(params.recipient)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `ClearOrigin` variant.
function clearOrigin() pure returns (Instruction memory) {
    return Instruction({variant: InstructionVariant.ClearOrigin, payload: ""});
}

/// @notice Creates an `Instruction` struct representing the `DescendOrigin` variant with the provided `params`.
function descendOrigin(
    DescendOriginParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.DescendOrigin,
            payload: JunctionsCodec.encode(params.interior)
        });
}

/// @notice Creates an `Instruction` struct representing the `ReportError` variant with the provided `params`.
function reportError(
    ReportErrorParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ReportError,
            payload: QueryResponseInfoCodec.encode(params.responseInfo)
        });
}

/// @notice Creates an `Instruction` struct representing the `DepositAsset` variant with the provided `params`.
function depositAsset(
    DepositAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.DepositAsset,
            payload: abi.encodePacked(
                AssetFilterCodec.encode(params.assets),
                LocationCodec.encode(params.beneficiary)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `DepositReserveAsset` variant with the provided `params`.
function depositReserveAsset(
    DepositReserveAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.DepositReserveAsset,
            payload: abi.encodePacked(
                AssetFilterCodec.encode(params.assets),
                LocationCodec.encode(params.dest),
                params.xcm
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `ExchangeAsset` variant with the provided `params`.
function exchangeAsset(
    ExchangeAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ExchangeAsset,
            payload: abi.encodePacked(
                AssetFilterCodec.encode(params.give),
                AssetsCodec.encode(params.want),
                Bool.encode(params.maximal)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `InitiateReserveWithdraw` variant with the provided `params`.
function initiateReserveWithdraw(
    InitiateReserveWithdrawParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.InitiateReserveWithdraw,
            payload: abi.encodePacked(
                AssetFilterCodec.encode(params.assets),
                LocationCodec.encode(params.reserve),
                params.xcm
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `InitiateTeleport` variant with the provided `params`.
function initiateTeleport(
    InitiateTeleportParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.InitiateTeleport,
            payload: abi.encodePacked(
                AssetFilterCodec.encode(params.assets),
                LocationCodec.encode(params.dest),
                params.xcm
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `ReportHolding` variant with the provided `params`.
function reportHolding(
    ReportHoldingParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ReportHolding,
            payload: abi.encodePacked(
                QueryResponseInfoCodec.encode(params.responseInfo),
                AssetFilterCodec.encode(params.assets)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `BuyExecution` variant with the provided `params`.
function buyExecution(
    BuyExecutionParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.BuyExecution,
            payload: abi.encodePacked(
                AssetCodec.encode(params.fees),
                WeightLimitCodec.encode(params.weightLimit)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `RefundSurplus` variant.
function refundSurplus() pure returns (Instruction memory) {
    return
        Instruction({variant: InstructionVariant.RefundSurplus, payload: ""});
}

/// @notice Creates an `Instruction` struct representing the `SetErrorHandler` variant with the provided `params`.
function setErrorHandler(
    SetErrorHandlerParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.SetErrorHandler,
            payload: params.xcm
        });
}

/// @notice Creates an `Instruction` struct representing the `SetAppendix` variant with the provided `params`.
function setAppendix(
    SetAppendixParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.SetAppendix,
            payload: params.xcm
        });
}

/// @notice Creates an `Instruction` struct representing the `ClearError` variant.
function clearError() pure returns (Instruction memory) {
    return Instruction({variant: InstructionVariant.ClearError, payload: ""});
}

/// @notice Creates an `Instruction` struct representing the `ClaimAsset` variant with the provided `params`.
function claimAsset(
    ClaimAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ClaimAsset,
            payload: abi.encodePacked(
                AssetsCodec.encode(params.assets),
                LocationCodec.encode(params.ticket)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `Trap` variant with the provided `params`.
function trap(TrapParams memory params) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.Trap,
            payload: Compact.encode(params.code)
        });
}

/// @notice Creates an `Instruction` struct representing the `SubscribeVersion` variant with the provided `params`.
function subscribeVersion(
    SubscribeVersionParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.SubscribeVersion,
            payload: abi.encodePacked(
                Compact.encode(uint256(QueryId.unwrap(params.queryId))),
                WeightCodec.encode(params.maxResponseWeight)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `UnsubscribeVersion` variant.
function unsubscribeVersion() pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.UnsubscribeVersion,
            payload: ""
        });
}

/// @notice Creates an `Instruction` struct representing the `BurnAsset` variant with the provided `params`.
function burnAsset(
    BurnAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.BurnAsset,
            payload: AssetsCodec.encode(params.assets)
        });
}

/// @notice Creates an `Instruction` struct representing the `ExpectAsset` variant with the provided `params`.
function expectAsset(
    ExpectAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ExpectAsset,
            payload: AssetsCodec.encode(params.assets)
        });
}

/// @notice Creates an `Instruction` struct representing the `ExpectOrigin` variant with the provided `params`.
function expectOrigin(
    ExpectOriginParams memory params
) pure returns (Instruction memory) {
    bytes memory payload = Bool.encode(params.hasOrigin);
    if (params.hasOrigin) {
        payload = abi.encodePacked(
            payload,
            LocationCodec.encode(params.origin)
        );
    }
    return
        Instruction({
            variant: InstructionVariant.ExpectOrigin,
            payload: payload
        });
}

/// @notice Creates an `Instruction` struct representing the `ExpectError` variant with the provided `params`.
function expectError(
    ExpectErrorParams memory params
) pure returns (Instruction memory) {
    bytes memory payload = Bool.encode(params.hasError);
    if (params.hasError) {
        payload = abi.encodePacked(
            payload,
            Compact.encode(params.index),
            XcmErrorCodec.encode(params.err)
        );
    }
    return
        Instruction({
            variant: InstructionVariant.ExpectError,
            payload: payload
        });
}

/// @notice Creates an `Instruction` struct representing the `ExpectTransactStatus` variant with the provided `params`.
function expectTransactStatus(
    ExpectTransactStatusParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ExpectTransactStatus,
            payload: MaybeErrorCodeCodec.encode(params.transactStatus)
        });
}

/// @notice Creates an `Instruction` struct representing the `QueryPallet` variant with the provided `params`.
function queryPallet(
    QueryPalletParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.QueryPallet,
            payload: abi.encodePacked(
                Bytes.encode(params.moduleName),
                QueryResponseInfoCodec.encode(params.responseInfo)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `ExpectPallet` variant with the provided `params`.
function expectPallet(
    ExpectPalletParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ExpectPallet,
            payload: abi.encodePacked(
                Compact.encode(params.index),
                Bytes.encode(params.name),
                Bytes.encode(params.moduleName),
                Compact.encode(params.crateMajor),
                Compact.encode(params.minCrateMinor)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `ReportTransactStatus` variant with the provided `params`.
function reportTransactStatus(
    ReportTransactStatusParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ReportTransactStatus,
            payload: QueryResponseInfoCodec.encode(params.responseInfo)
        });
}

/// @notice Creates an `Instruction` struct representing the `ClearTransactStatus` variant.
function clearTransactStatus() pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ClearTransactStatus,
            payload: ""
        });
}

/// @notice Creates an `Instruction` struct representing the `UniversalOrigin` variant with the provided `params`.
function universalOrigin(
    UniversalOriginParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.UniversalOrigin,
            payload: JunctionCodec.encode(params.junction)
        });
}

/// @notice Creates an `Instruction` struct representing the `ExportMessage` variant with the provided `params`.
function exportMessage(
    ExportMessageParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.ExportMessage,
            payload: abi.encodePacked(
                NetworkIdCodec.encode(params.network),
                JunctionsCodec.encode(params.destination),
                params.xcm
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `LockAsset` variant with the provided `params`.
function lockAsset(
    LockAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.LockAsset,
            payload: abi.encodePacked(
                AssetCodec.encode(params.asset),
                LocationCodec.encode(params.unlocker)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `UnlockAsset` variant with the provided `params`.
function unlockAsset(
    UnlockAssetParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.UnlockAsset,
            payload: abi.encodePacked(
                AssetCodec.encode(params.asset),
                LocationCodec.encode(params.target)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `NoteUnlockable` variant with the provided `params`.
function noteUnlockable(
    NoteUnlockableParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.NoteUnlockable,
            payload: abi.encodePacked(
                AssetCodec.encode(params.asset),
                LocationCodec.encode(params.owner)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `RequestUnlock` variant with the provided `params`.
function requestUnlock(
    RequestUnlockParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.RequestUnlock,
            payload: abi.encodePacked(
                AssetCodec.encode(params.asset),
                LocationCodec.encode(params.locker)
            )
        });
}

/// @notice Creates an `Instruction` struct representing the `SetFeesMode` variant with the provided `params`.
function setFeesMode(
    SetFeesModeParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.SetFeesMode,
            payload: Bool.encode(params.jitWithdraw)
        });
}

/// @notice Creates an `Instruction` struct representing the `SetTopic` variant with the provided `params`.
function setTopic(
    SetTopicParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.SetTopic,
            payload: Bytes32.encode(params.topic)
        });
}

/// @notice Creates an `Instruction` struct representing the `ClearTopic` variant.
function clearTopic() pure returns (Instruction memory) {
    return Instruction({variant: InstructionVariant.ClearTopic, payload: ""});
}

/// @notice Creates an `Instruction` struct representing the `AliasOrigin` variant with the provided `params`.
function aliasOrigin(
    AliasOriginParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.AliasOrigin,
            payload: LocationCodec.encode(params.location)
        });
}

/// @notice Creates an `Instruction` struct representing the `UnpaidExecution` variant with the provided `params`.
function unpaidExecution(
    UnpaidExecutionParams memory params
) pure returns (Instruction memory) {
    bytes memory payload = abi.encodePacked(
        WeightLimitCodec.encode(params.weightLimit),
        Bool.encode(params.hasCheckOrigin)
    );
    if (params.hasCheckOrigin) {
        payload = abi.encodePacked(
            payload,
            LocationCodec.encode(params.checkOrigin)
        );
    }
    return
        Instruction({
            variant: InstructionVariant.UnpaidExecution,
            payload: payload
        });
}

/// @notice Creates an `Instruction` struct representing the `PayFees` variant with the provided `params`.
function payFees(
    PayFeesParams memory params
) pure returns (Instruction memory) {
    return
        Instruction({
            variant: InstructionVariant.PayFees,
            payload: AssetCodec.encode(params.asset)
        });
}

/// @notice Creates an `Instruction` struct representing the `InitiateTransfer` variant with the provided `params`.
function initiateTransfer(
    InitiateTransferParams memory params
) pure returns (Instruction memory) {
    if (params.assets.length > MAX_ASSET_TRANSFER_FILTERS) {
        revert InvalidInstruction();
    }
    bytes memory payload = abi.encodePacked(
        LocationCodec.encode(params.destination),
        Bool.encode(params.hasRemoteFees)
    );
    if (params.hasRemoteFees) {
        payload = abi.encodePacked(
            payload,
            AssetTransferFilterCodec.encode(params.remoteFees)
        );
    }
    payload = abi.encodePacked(
        payload,
        Bool.encode(params.preserveOrigin),
        Compact.encode(params.assets.length)
    );
    for (uint256 i = 0; i < params.assets.length; i++) {
        payload = abi.encodePacked(
            payload,
            AssetTransferFilterCodec.encode(params.assets[i])
        );
    }
    payload = abi.encodePacked(
        payload,
        Compact.encode(params.remoteXcm.length),
        params.remoteXcm
    );
    return
        Instruction({
            variant: InstructionVariant.InitiateTransfer,
            payload: payload
        });
}

/// @notice Creates an `Instruction` struct representing the `ExecuteWithOrigin` variant with the provided `params`.
function executeWithOrigin(
    ExecuteWithOriginParams memory params
) pure returns (Instruction memory) {
    bytes memory payload = Bool.encode(params.hasDescendantOrigin);
    if (params.hasDescendantOrigin) {
        payload = abi.encodePacked(
            payload,
            JunctionsCodec.encode(params.descendantOrigin)
        );
    }
    payload = abi.encodePacked(payload, params.xcm);
    return
        Instruction({
            variant: InstructionVariant.ExecuteWithOrigin,
            payload: payload
        });
}

/// @notice Creates an `Instruction` struct representing the `SetHints` variant with the provided `params`.
function setHints(
    SetHintsParams memory params
) pure returns (Instruction memory) {
    if (params.hints.length > HINT_NUM_VARIANTS) {
        revert InvalidInstruction();
    }
    bytes memory payload = Compact.encode(params.hints.length);
    for (uint256 i = 0; i < params.hints.length; i++) {
        payload = abi.encodePacked(payload, HintCodec.encode(params.hints[i]));
    }
    return
        Instruction({variant: InstructionVariant.SetHints, payload: payload});
}
