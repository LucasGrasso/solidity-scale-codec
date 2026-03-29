// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetsCodec, Assets} from "./Assets.sol";
import {LocationCodec, Location} from "./Location.sol";
import {OriginKindCodec, OriginKind} from "./OriginKind.sol";
import {WeightCodec, Weight} from "./Weight.sol";
import {AssetsFilterCodec, AssetFilter} from "./AssetFilter.sol";

/// @notice Discriminant for the `Instruction` enum, representing the type of instruction being executed.
enum InstructionType {
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

/// @notice Params for `QueryResponse` instruction.
struct QueryResponseParams {
    /// @custom:property The identifier of the query that resulted in this message being sent.
    uint64 queryId;
    /// @custom:property The message content.
    Response response;
    /// @custom:property The maximum weight that handling this response should take.
    Weight maxWeight;
    /// @custom:property Indicates whether the querier field contains valid data.
    bool hasQuerier;
    /// @custom:property The location responsible for the initiation of the response, if there is one. In general this will tend to be the same location as the receiver of this message. NOTE: As usual, this is interpreted from the perspective of the receiving consensus system.
    Location querier;
}

/// @notice Params for `TransferAsset` instruction.
struct TransferAssetParams {
    /// @custom:property The asset(s) to be withdrawn.
    Assets assets;
    /// @custom:property The new owner for the assets.
    Location beneficiary;
}

/// @notice Params for `TransferReserveAsset` instruction.
struct TransferReserveAssetParams {
    /// @custom:property The asset(s) to be withdrawn.
    Assets assets;
    /// @custom:property The location whose sovereign account will own the assets and thus the effective beneficiary for the assets and the notification target for the reserve asset deposit message.
    Location dest;
    /// @custom:property The encoded instructions that should follow the `ReserveAssetDeposited` instruction, which is sent onwards to `dest`. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `Transact` instruction.
struct TransactParams {
    /// @custom:property The means of expressing the message origin as a dispatch origin.
    OriginKind originKind;
    /// @custom:property Indicates whether the fallbackMaxWeight field contains valid data.
    bool hasFallbackMaxWeight;
    /// @custom:property Used for compatibility with previous versions. Corresponds to `require_weight_at_most` in previous versions. If you don't care about compatibility you can set hasFallbackMaxWeight=false. WARNING: If you do, your XCM might not work with older versions.
    Weight fallbackMaxWeight;
    /// @custom:property The encoded transaction to be applied. DoubleEncoded<Call>: compact-length-prefixed raw bytes.
    bytes call;
}

/// @notice Params for `HrmpNewChannelOpenRequest` instruction.
struct HrmpNewChannelOpenRequestParams {
    /// @custom:property The sender in the to-be opened channel. Also, the initiator of the channel opening.
    uint32 sender;
    /// @custom:property The maximum size of a message proposed by the sender.
    uint32 maxMessageSize;
    /// @custom:property The maximum number of messages that can be queued in the channel.
    uint32 maxCapacity;
}

/// @notice Params for `HrmpChannelAccepted` instruction.
struct HrmpChannelAcceptedParams {
    /// @custom:property The recipient of the channel that was accepted.
    uint32 recipient;
}

/// @notice Params for `HrmpChannelClosing` instruction.
struct HrmpChannelClosingParams {
    /// @custom:property The initiator of the channel closing.
    uint32 initiator;
    /// @custom:property The sender of the channel being closed.
    uint32 sender;
    /// @custom:property The recipient of the channel being closed.
    uint32 recipient;
}

/// @notice Params for `DepositAsset` instruction.
struct DepositAssetParams {
    /// @custom:property The asset(s) to remove from holding.
    AssetFilter assets;
    /// @custom:property The new owner for the assets.
    Location beneficiary;
}

/// @notice Params for `DepositReserveAsset` instruction.
struct DepositReserveAssetParams {
    /// @custom:property The asset(s) to remove from holding.
    AssetFilter assets;
    /// @custom:property The location whose sovereign account will own the assets and thus the effective beneficiary for the assets and the notification target for the reserve asset deposit message.
    Location dest;
    /// @custom:property The orders that should follow the `ReserveAssetDeposited` instruction which is sent onwards to `dest`. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `ExchangeAsset` instruction.
struct ExchangeAssetParams {
    /// @custom:property The maximum amount of assets to remove from holding.
    AssetFilter give;
    /// @custom:property The minimum amount of assets which `give` should be exchanged for.
    Assets want;
    /// @custom:property If true, prefer to give as much as possible up to the limit of `give` and receive accordingly more. If false, prefer to give as little as possible while receiving at least `want`.
    bool maximal;
}

/// @notice Params for `InitiateReserveWithdraw` instruction.
struct InitiateReserveWithdrawParams {
    /// @custom:property The asset(s) to remove from holding.
    AssetFilter assets;
    /// @custom:property A valid location that acts as a reserve for all asset(s) in `assets`. There will typically be only one valid location on any given asset/chain combination.
    Location reserve;
    /// @custom:property The instructions to execute on the assets once withdrawn on the reserve location. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `InitiateTeleport` instruction.
struct InitiateTeleportParams {
    /// @custom:property The asset(s) to remove from holding.
    AssetFilter assets;
    /// @custom:property A valid location that respects teleports coming from this location. NOTE: `dest` MUST respect this origin as a valid teleportation origin for all `assets`, otherwise the assets may be lost.
    Location dest;
    /// @custom:property The instructions to execute on the assets once arrived on the destination location. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `ReportHolding` instruction.
struct ReportHoldingParams {
    /// @custom:property Information for making the response.
    QueryResponseInfo responseInfo;
    /// @custom:property A filter for the assets that should be reported back. The assets reported back will be, asset-wise, the lesser of this value and the holding register. No wildcards will be used when reporting assets back.
    AssetFilter assets;
}

/// @notice Params for `BuyExecution` instruction.
struct BuyExecutionParams {
    /// @custom:property The asset(s) to remove from the Holding Register to pay for fees.
    Asset fees;
    /// @custom:property The maximum amount of weight to purchase; this must be at least the expected maximum weight of the total XCM to be executed for the `AllowTopLevelPaidExecutionFrom` barrier to allow the XCM to be executed.
    WeightLimit weightLimit;
}

/// @notice Params for `ClaimAsset` instruction.
struct ClaimAssetParams {
    /// @custom:property The assets which are to be claimed. This must match exactly with the assets claimable by the origin of the ticket.
    Assets assets;
    /// @custom:property The ticket of the asset; this is an abstract identifier to help locate the asset.
    Location ticket;
}

/// @notice Params for `SubscribeVersion` instruction.
struct SubscribeVersionParams {
    /// @custom:property An identifier that will be replicated into the returned XCM message.
    uint64 queryId;
    /// @custom:property The maximum amount of weight that the `QueryResponse` item which is sent as a reply may take to execute. NOTE: If this is unexpectedly large then the response may not execute at all.
    Weight maxResponseWeight;
}

/// @notice Params for `QueryPallet` instruction.
struct QueryPalletParams {
    /// @custom:property The module name of the pallet to query. SCALE-encoded Vec<u8>.
    bytes moduleName;
    /// @custom:property Information for making the response.
    QueryResponseInfo responseInfo;
}

/// @notice Params for `ExpectPallet` instruction.
struct ExpectPalletParams {
    /// @custom:property The index which identifies the pallet. An error if no pallet exists at this index.
    uint32 index;
    /// @custom:property Name which must be equal to the name of the pallet. SCALE-encoded Vec<u8>.
    bytes name;
    /// @custom:property Module name which must be equal to the name of the module in which the pallet exists. SCALE-encoded Vec<u8>.
    bytes moduleName;
    /// @custom:property Version number which must be equal to the major version of the crate which implements the pallet.
    uint32 crateMajor;
    /// @custom:property Version number which must be at most the minor version of the crate which implements the pallet.
    uint32 minCrateMinor;
}

/// @notice Params for `ExportMessage` instruction.
struct ExportMessageParams {
    /// @custom:property The remote consensus system to which the message should be exported.
    NetworkId network;
    /// @custom:property The location relative to the remote consensus system to which the message should be sent on arrival.
    InteriorLocation destination;
    /// @custom:property The message to be exported. SCALE-encoded Xcm<()>.
    bytes xcm;
}

/// @notice Params for `LockAsset` instruction.
struct LockAssetParams {
    /// @custom:property The asset(s) which should be locked.
    Asset asset;
    /// @custom:property The value which the Origin must be for a corresponding `UnlockAsset` instruction to work.
    Location unlocker;
}

/// @notice Params for `UnlockAsset` instruction.
struct UnlockAssetParams {
    /// @custom:property The asset to be unlocked.
    Asset asset;
    /// @custom:property The owner of the asset on the local chain.
    Location target;
}

/// @notice Params for `NoteUnlockable` instruction.
struct NoteUnlockableParams {
    /// @custom:property The asset(s) which are now unlockable from this origin.
    Asset asset;
    /// @custom:property The owner of the asset on the chain in which it was locked. This may be a location specific to the origin network.
    Location owner;
}

/// @notice Params for `RequestUnlock` instruction.
struct RequestUnlockParams {
    /// @custom:property The asset(s) to be unlocked.
    Asset asset;
    /// @custom:property The location from which a previous `NoteUnlockable` was sent and to which an `UnlockAsset` should be sent.
    Location locker;
}

/// @notice Params for `SetFeesMode` instruction.
struct SetFeesModeParams {
    /// @custom:property If true, fees for any instructions are withdrawn as needed using the same mechanism as `WithdrawAssets`.
    bool jitWithdraw;
}

/// @notice Params for `UnpaidExecution` instruction.
struct UnpaidExecutionParams {
    /// @custom:property The maximum amount of weight to use for free execution.
    WeightLimit weightLimit;
    /// @custom:property Indicates whether the checkOrigin field contains valid data.
    bool hasCheckOrigin;
    /// @custom:property If set, the origin must equal this location for free execution to be granted.
    Location checkOrigin;
}

/// @notice Params for `PayFees` instruction.
struct PayFeesParams {
    /// @custom:property The asset to use for paying execution fees.
    Asset asset;
}

/// @notice Params for `InitiateTransfer` instruction.
struct InitiateTransferParams {
    /// @custom:property The location of the program next hop.
    Location destination;
    /// @custom:property Indicates whether the remoteFees field contains valid data.
    bool hasRemoteFees;
    /// @custom:property If set, the single asset matching this filter will be transferred first for fees via `PayFees`. If not set, a `UnpaidExecution` instruction is used instead. Assets are reserved for fees and sent to the fees register rather than holding.
    AssetTransferFilter remoteFees;
    /// @custom:property Specifies whether the original origin should be preserved (`AliasOrigin`) or cleared (`ClearOrigin`).
    bool preserveOrigin;
    /// @custom:property List of asset filters matched against existing assets in holding, transferred to `destination`. Max 6 elements (MaxAssetTransferFilters).
    AssetTransferFilter[] assets;
    /// @custom:property Custom instructions executed on `destination` after a `ClearOrigin`, so their origin will be `None`. SCALE-encoded Xcm<()>.
    bytes remoteXcm;
}

/// @notice Params for `ExecuteWithOrigin` instruction.
struct ExecuteWithOriginParams {
    /// @custom:property Indicates whether the descendantOrigin field contains valid data.
    bool hasDescendantOrigin;
    /// @custom:property If set, inner xcm executes as if `DescendOrigin(o)` was called first, with origin = `original_origin.append_with(o)`. If not set, inner xcm executes with no origin.
    InteriorLocation descendantOrigin;
    /// @custom:property Inner instructions executed with the modified origin. SCALE-encoded Xcm<Call>.
    bytes xcm;
}

/// @notice Params for `SetHints` instruction.
struct SetHintsParams {
    /// @custom:property A bounded vector of hints specifying different behaviours to activate. SCALE-encoded BoundedVec<Hint, HintNumVariants>.
    bytes hints;
}
