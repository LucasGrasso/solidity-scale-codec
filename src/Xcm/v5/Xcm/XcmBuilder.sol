// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {aliasOrigin as _aliasOrigin, burnAsset as _burnAsset, buyExecution as _buyExecution, claimAsset as _claimAsset, clearError as _clearError, clearOrigin as _clearOrigin, clearTopic as _clearTopic, clearTransactStatus as _clearTransactStatus, depositAsset as _depositAsset, depositReserveAsset as _depositReserveAsset, descendOrigin as _descendOrigin, executeWithOrigin as _executeWithOrigin, expectAsset as _expectAsset, expectError as _expectError, expectOrigin as _expectOrigin, expectPallet as _expectPallet, expectTransactStatus as _expectTransactStatus, exchangeAsset as _exchangeAsset, exportMessage as _exportMessage, hrmpChannelAccepted as _hrmpChannelAccepted, hrmpChannelClosing as _hrmpChannelClosing, hrmpNewChannelOpenRequest as _hrmpNewChannelOpenRequest, initiateReserveWithdraw as _initiateReserveWithdraw, initiateTeleport as _initiateTeleport, initiateTransfer as _initiateTransfer, lockAsset as _lockAsset, noteUnlockable as _noteUnlockable, payFees as _payFees, queryPallet as _queryPallet, queryResponse as _queryResponse, receiveTeleportedAsset as _receiveTeleportedAsset, refundSurplus as _refundSurplus, reportError as _reportError, reportHolding as _reportHolding, reportTransactStatus as _reportTransactStatus, requestUnlock as _requestUnlock, reserveAssetDeposited as _reserveAssetDeposited, setAppendix as _setAppendix, setErrorHandler as _setErrorHandler, setFeesMode as _setFeesMode, setHints as _setHints, setTopic as _setTopic, subscribeVersion as _subscribeVersion, transact as _transact, transferAsset as _transferAsset, transferReserveAsset as _transferReserveAsset, trap as _trap, universalOrigin as _universalOrigin, unpaidExecution as _unpaidExecution, unlockAsset as _unlockAsset, unsubscribeVersion as _unsubscribeVersion, withdrawAsset as _withdrawAsset, AliasOriginParams, BurnAssetParams, BuyExecutionParams, ClaimAssetParams, DepositAssetParams, DepositReserveAssetParams, DescendOriginParams, ExecuteWithOriginParams, ExpectAssetParams, ExpectErrorParams, ExpectOriginParams, ExpectPalletParams, ExpectTransactStatusParams, ExchangeAssetParams, ExportMessageParams, HrmpChannelAcceptedParams, HrmpChannelClosingParams, HrmpNewChannelOpenRequestParams, InitiateReserveWithdrawParams, InitiateTeleportParams, InitiateTransferParams, Instruction, LockAssetParams, NoteUnlockableParams, PayFeesParams, QueryPalletParams, QueryResponseParams, ReceiveTeleportedAssetParams, ReportErrorParams, ReportHoldingParams, ReportTransactStatusParams, RequestUnlockParams, ReserveAssetDepositedParams, SetAppendixParams, SetErrorHandlerParams, SetFeesModeParams, SetHintsParams, SetTopicParams, SubscribeVersionParams, TransactParams, TransferAssetParams, TransferReserveAssetParams, TrapParams, UniversalOriginParams, UnpaidExecutionParams, UnlockAssetParams, WithdrawAssetParams} from "../Instruction/Instruction.sol";
import {Xcm, fromInstructions, newXcm} from "./Xcm.sol";

/// @title XcmBuilder
/// @notice A library for building XCM v5 `Xcm` programs using a fluent interface.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library XcmBuilder {
    /// @notice Creates a new empty XCM program.
    /// @return An `Xcm` instance with no instructions.
    function create() internal pure returns (Xcm memory) {
        return newXcm();
    }

    /// @notice Creates an XCM program from an instruction array.
    /// @param instructions Ordered instructions to include in the program.
    /// @return An `Xcm` instance containing `instructions`.
    function from(
        Instruction[] memory instructions
    ) internal pure returns (Xcm memory) {
        return fromInstructions(instructions);
    }

    /// @notice Appends a `WithdrawAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function withdrawAsset(
        Xcm memory xcm,
        WithdrawAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _withdrawAsset(params));
    }

    /// @notice Appends a `ReserveAssetDeposited` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function reserveAssetDeposited(
        Xcm memory xcm,
        ReserveAssetDepositedParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _reserveAssetDeposited(params));
    }

    /// @notice Appends a `ReceiveTeleportedAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function receiveTeleportedAsset(
        Xcm memory xcm,
        ReceiveTeleportedAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _receiveTeleportedAsset(params));
    }

    /// @notice Appends a `QueryResponse` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function queryResponse(
        Xcm memory xcm,
        QueryResponseParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _queryResponse(params));
    }

    /// @notice Appends a `TransferAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function transferAsset(
        Xcm memory xcm,
        TransferAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _transferAsset(params));
    }

    /// @notice Appends a `TransferReserveAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function transferReserveAsset(
        Xcm memory xcm,
        TransferReserveAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _transferReserveAsset(params));
    }

    /// @notice Appends a `Transact` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function transact(
        Xcm memory xcm,
        TransactParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _transact(params));
    }

    /// @notice Appends a `HrmpNewChannelOpenRequest` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function hrmpNewChannelOpenRequest(
        Xcm memory xcm,
        HrmpNewChannelOpenRequestParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _hrmpNewChannelOpenRequest(params));
    }

    /// @notice Appends a `HrmpChannelAccepted` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function hrmpChannelAccepted(
        Xcm memory xcm,
        HrmpChannelAcceptedParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _hrmpChannelAccepted(params));
    }

    /// @notice Appends a `HrmpChannelClosing` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function hrmpChannelClosing(
        Xcm memory xcm,
        HrmpChannelClosingParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _hrmpChannelClosing(params));
    }

    /// @notice Appends a `ClearOrigin` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @return A new program with the instruction appended.
    function clearOrigin(Xcm memory xcm) internal pure returns (Xcm memory) {
        return _append(xcm, _clearOrigin());
    }

    /// @notice Appends a `DescendOrigin` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function descendOrigin(
        Xcm memory xcm,
        DescendOriginParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _descendOrigin(params));
    }

    /// @notice Appends a `ReportError` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function reportError(
        Xcm memory xcm,
        ReportErrorParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _reportError(params));
    }

    /// @notice Appends a `DepositAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function depositAsset(
        Xcm memory xcm,
        DepositAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _depositAsset(params));
    }

    /// @notice Appends a `DepositReserveAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function depositReserveAsset(
        Xcm memory xcm,
        DepositReserveAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _depositReserveAsset(params));
    }

    /// @notice Appends an `ExchangeAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function exchangeAsset(
        Xcm memory xcm,
        ExchangeAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _exchangeAsset(params));
    }

    /// @notice Appends an `InitiateReserveWithdraw` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function initiateReserveWithdraw(
        Xcm memory xcm,
        InitiateReserveWithdrawParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _initiateReserveWithdraw(params));
    }

    /// @notice Appends an `InitiateTeleport` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function initiateTeleport(
        Xcm memory xcm,
        InitiateTeleportParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _initiateTeleport(params));
    }

    /// @notice Appends a `ReportHolding` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function reportHolding(
        Xcm memory xcm,
        ReportHoldingParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _reportHolding(params));
    }

    /// @notice Appends a `BuyExecution` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function buyExecution(
        Xcm memory xcm,
        BuyExecutionParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _buyExecution(params));
    }

    /// @notice Appends a `RefundSurplus` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @return A new program with the instruction appended.
    function refundSurplus(Xcm memory xcm) internal pure returns (Xcm memory) {
        return _append(xcm, _refundSurplus());
    }

    /// @notice Appends a `SetErrorHandler` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function setErrorHandler(
        Xcm memory xcm,
        SetErrorHandlerParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _setErrorHandler(params));
    }

    /// @notice Appends a `SetAppendix` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function setAppendix(
        Xcm memory xcm,
        SetAppendixParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _setAppendix(params));
    }

    /// @notice Appends a `ClearError` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @return A new program with the instruction appended.
    function clearError(Xcm memory xcm) internal pure returns (Xcm memory) {
        return _append(xcm, _clearError());
    }

    /// @notice Appends a `ClaimAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function claimAsset(
        Xcm memory xcm,
        ClaimAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _claimAsset(params));
    }

    /// @notice Appends a `Trap` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function trap(
        Xcm memory xcm,
        TrapParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _trap(params));
    }

    /// @notice Appends a `SubscribeVersion` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function subscribeVersion(
        Xcm memory xcm,
        SubscribeVersionParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _subscribeVersion(params));
    }

    /// @notice Appends an `UnsubscribeVersion` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @return A new program with the instruction appended.
    function unsubscribeVersion(
        Xcm memory xcm
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _unsubscribeVersion());
    }

    /// @notice Appends a `BurnAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function burnAsset(
        Xcm memory xcm,
        BurnAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _burnAsset(params));
    }

    /// @notice Appends an `ExpectAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function expectAsset(
        Xcm memory xcm,
        ExpectAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _expectAsset(params));
    }

    /// @notice Appends an `ExpectOrigin` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function expectOrigin(
        Xcm memory xcm,
        ExpectOriginParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _expectOrigin(params));
    }

    /// @notice Appends an `ExpectError` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function expectError(
        Xcm memory xcm,
        ExpectErrorParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _expectError(params));
    }

    /// @notice Appends an `ExpectTransactStatus` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function expectTransactStatus(
        Xcm memory xcm,
        ExpectTransactStatusParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _expectTransactStatus(params));
    }

    /// @notice Appends a `QueryPallet` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function queryPallet(
        Xcm memory xcm,
        QueryPalletParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _queryPallet(params));
    }

    /// @notice Appends an `ExpectPallet` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function expectPallet(
        Xcm memory xcm,
        ExpectPalletParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _expectPallet(params));
    }

    /// @notice Appends a `ReportTransactStatus` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function reportTransactStatus(
        Xcm memory xcm,
        ReportTransactStatusParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _reportTransactStatus(params));
    }

    /// @notice Appends a `ClearTransactStatus` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @return A new program with the instruction appended.
    function clearTransactStatus(
        Xcm memory xcm
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _clearTransactStatus());
    }

    /// @notice Appends a `UniversalOrigin` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function universalOrigin(
        Xcm memory xcm,
        UniversalOriginParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _universalOrigin(params));
    }

    /// @notice Appends an `ExportMessage` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function exportMessage(
        Xcm memory xcm,
        ExportMessageParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _exportMessage(params));
    }

    /// @notice Appends a `LockAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function lockAsset(
        Xcm memory xcm,
        LockAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _lockAsset(params));
    }

    /// @notice Appends an `UnlockAsset` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function unlockAsset(
        Xcm memory xcm,
        UnlockAssetParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _unlockAsset(params));
    }

    /// @notice Appends a `NoteUnlockable` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function noteUnlockable(
        Xcm memory xcm,
        NoteUnlockableParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _noteUnlockable(params));
    }

    /// @notice Appends a `RequestUnlock` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function requestUnlock(
        Xcm memory xcm,
        RequestUnlockParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _requestUnlock(params));
    }

    /// @notice Appends a `SetFeesMode` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function setFeesMode(
        Xcm memory xcm,
        SetFeesModeParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _setFeesMode(params));
    }

    /// @notice Appends a `SetTopic` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function setTopic(
        Xcm memory xcm,
        SetTopicParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _setTopic(params));
    }

    /// @notice Appends a `ClearTopic` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @return A new program with the instruction appended.
    function clearTopic(Xcm memory xcm) internal pure returns (Xcm memory) {
        return _append(xcm, _clearTopic());
    }

    /// @notice Appends an `AliasOrigin` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function aliasOrigin(
        Xcm memory xcm,
        AliasOriginParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _aliasOrigin(params));
    }

    /// @notice Appends an `UnpaidExecution` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function unpaidExecution(
        Xcm memory xcm,
        UnpaidExecutionParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _unpaidExecution(params));
    }

    /// @notice Appends a `PayFees` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function payFees(
        Xcm memory xcm,
        PayFeesParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _payFees(params));
    }

    /// @notice Appends an `InitiateTransfer` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function initiateTransfer(
        Xcm memory xcm,
        InitiateTransferParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _initiateTransfer(params));
    }

    /// @notice Appends an `ExecuteWithOrigin` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function executeWithOrigin(
        Xcm memory xcm,
        ExecuteWithOriginParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _executeWithOrigin(params));
    }

    /// @notice Appends a `SetHints` instruction to an XCM program.
    /// @param xcm The program to extend.
    /// @param params The instruction parameters.
    /// @return A new program with the instruction appended.
    function setHints(
        Xcm memory xcm,
        SetHintsParams memory params
    ) internal pure returns (Xcm memory) {
        return _append(xcm, _setHints(params));
    }

    function _append(
        Xcm memory xcm,
        Instruction memory instruction
    ) private pure returns (Xcm memory) {
        uint256 length = xcm.instructions.length;
        Instruction[] memory instructions = new Instruction[](length + 1);

        for (uint256 i = 0; i < length; ++i) {
            instructions[i] = xcm.instructions[i];
        }

        instructions[length] = instruction;
        return fromInstructions(instructions);
    }
}
