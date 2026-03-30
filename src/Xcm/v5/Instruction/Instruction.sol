// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

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
