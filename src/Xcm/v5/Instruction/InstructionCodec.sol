// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AliasOriginParams, BurnAssetParams, BuyExecutionParams, ClaimAssetParams, DepositAssetParams, DepositReserveAssetParams, DescendOriginParams, ExecuteWithOriginParams, ExchangeAssetParams, ExpectAssetParams, ExpectErrorParams, ExpectOriginParams, ExpectPalletParams, ExpectTransactStatusParams, ExportMessageParams, HrmpChannelAcceptedParams, HrmpChannelClosingParams, HrmpNewChannelOpenRequestParams, InitiateReserveWithdrawParams, InitiateTeleportParams, InitiateTransferParams, Instruction, InstructionVariant, LockAssetParams, NoteUnlockableParams, PayFeesParams, QueryPalletParams, QueryResponseParams, ReceiveTeleportedAssetParams, ReportErrorParams, ReportHoldingParams, ReportTransactStatusParams, RequestUnlockParams, ReserveAssetDepositedParams, SetAppendixParams, SetErrorHandlerParams, SetFeesModeParams, SetHintsParams, SetTopicParams, SubscribeVersionParams, TransactParams, TransferAssetParams, TransferReserveAssetParams, TrapParams, UnlockAssetParams, UniversalOriginParams, UnpaidExecutionParams, WithdrawAssetParams} from "./Instruction.sol";
import {AssetTransferFilter} from "../AssetTransferFilter/AssetTransferFilter.sol";
import {Hint} from "../Hint/Hint.sol";
import {QueryId} from "../Types/QueryId.sol";
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

import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `Instruction`
/// @notice SCALE-compliant encoder/decoder for the `Instruction` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library InstructionCodec {
    error InvalidInstructionLength();
    error InvalidInstructionVariant(uint8 variant);
    error InvalidInstructionPayload();

    /// @notice Encodes an `Instruction` into SCALE bytes.
    /// @param instruction The `Instruction` struct to encode.
    /// @return SCALE-encoded bytes representing the instruction.
    function encode(
        Instruction memory instruction
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(uint8(instruction.variant), instruction.payload);
    }

    /// @notice Returns the number of bytes that an `Instruction` occupies when SCALE-encoded.
    /// @param data The byte sequence containing the encoded instruction.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded instruction.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidInstructionLength();

        uint8 variantRaw = uint8(data[offset]);
        if (variantRaw > uint8(type(InstructionVariant).max)) {
            revert InvalidInstructionVariant(variantRaw);
        }

        InstructionVariant variant = InstructionVariant(variantRaw);
        uint256 pos = offset + 1;

        if (
            variant == InstructionVariant.WithdrawAsset ||
            variant == InstructionVariant.ReserveAssetDeposited ||
            variant == InstructionVariant.ReceiveTeleportedAsset ||
            variant == InstructionVariant.BurnAsset ||
            variant == InstructionVariant.ExpectAsset
        ) {
            pos += AssetsCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.QueryResponse) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += ResponseCodec.encodedSizeAt(data, pos);
            pos += WeightCodec.encodedSizeAt(data, pos);
            bool hasQuerier = Bool.decodeAt(data, pos);
            ++pos;
            if (hasQuerier) {
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
        } else if (variant == InstructionVariant.TransferAsset) {
            pos += AssetsCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (
            variant == InstructionVariant.TransferReserveAsset ||
            variant == InstructionVariant.DepositReserveAsset ||
            variant == InstructionVariant.InitiateReserveWithdraw ||
            variant == InstructionVariant.InitiateTeleport
        ) {
            if (variant == InstructionVariant.TransferReserveAsset) {
                pos += AssetsCodec.encodedSizeAt(data, pos);
                pos += LocationCodec.encodedSizeAt(data, pos);
            } else {
                pos += AssetFilterCodec.encodedSizeAt(data, pos);
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.Transact) {
            pos += OriginKindCodec.encodedSizeAt(data, pos);
            bool hasFallbackMaxWeight = Bool.decodeAt(data, pos);
            ++pos;
            if (hasFallbackMaxWeight) {
                pos += WeightCodec.encodedSizeAt(data, pos);
            }
            pos += Bytes.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.HrmpNewChannelOpenRequest) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.HrmpChannelAccepted) {
            pos += Compact.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.HrmpChannelClosing) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
        } else if (
            variant == InstructionVariant.ClearOrigin ||
            variant == InstructionVariant.RefundSurplus ||
            variant == InstructionVariant.ClearError ||
            variant == InstructionVariant.UnsubscribeVersion ||
            variant == InstructionVariant.ClearTransactStatus ||
            variant == InstructionVariant.ClearTopic
        ) {
            // no payload
            return pos - offset;
        } else if (variant == InstructionVariant.DescendOrigin) {
            pos += JunctionsCodec.encodedSizeAt(data, pos);
        } else if (
            variant == InstructionVariant.ReportError ||
            variant == InstructionVariant.ReportTransactStatus
        ) {
            pos += QueryResponseInfoCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.DepositAsset) {
            pos += AssetFilterCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.ExchangeAsset) {
            pos += AssetFilterCodec.encodedSizeAt(data, pos);
            pos += AssetsCodec.encodedSizeAt(data, pos);
            ++pos;
        } else if (variant == InstructionVariant.ReportHolding) {
            pos += QueryResponseInfoCodec.encodedSizeAt(data, pos);
            pos += AssetFilterCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.BuyExecution) {
            pos += AssetCodec.encodedSizeAt(data, pos);
            pos += WeightLimitCodec.encodedSizeAt(data, pos);
        } else if (
            variant == InstructionVariant.SetErrorHandler ||
            variant == InstructionVariant.SetAppendix
        ) {
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.ClaimAsset) {
            pos += AssetsCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.Trap) {
            pos += Compact.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.SubscribeVersion) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += WeightCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.ExpectOrigin) {
            bool hasOrigin = Bool.decodeAt(data, pos);
            ++pos;
            if (hasOrigin) {
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
        } else if (variant == InstructionVariant.ExpectError) {
            bool hasError = Bool.decodeAt(data, pos);
            ++pos;
            if (hasError) {
                pos += Compact.encodedSizeAt(data, pos);
                pos += XcmErrorCodec.encodedSizeAt(data, pos);
            }
        } else if (variant == InstructionVariant.ExpectTransactStatus) {
            pos += MaybeErrorCodeCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.QueryPallet) {
            pos += Bytes.encodedSizeAt(data, pos);
            pos += QueryResponseInfoCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.ExpectPallet) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += Bytes.encodedSizeAt(data, pos);
            pos += Bytes.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.UniversalOrigin) {
            pos += JunctionCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.ExportMessage) {
            pos += NetworkIdCodec.encodedSizeAt(data, pos);
            pos += JunctionsCodec.encodedSizeAt(data, pos);
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (
            variant == InstructionVariant.LockAsset ||
            variant == InstructionVariant.UnlockAsset ||
            variant == InstructionVariant.NoteUnlockable ||
            variant == InstructionVariant.RequestUnlock
        ) {
            pos += AssetCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.SetFeesMode) {
            ++pos;
        } else if (variant == InstructionVariant.SetTopic) {
            if (data.length < pos + 32) revert InvalidInstructionPayload();
            pos += 32;
        } else if (variant == InstructionVariant.AliasOrigin) {
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.UnpaidExecution) {
            pos += WeightLimitCodec.encodedSizeAt(data, pos);
            bool hasCheckOrigin = Bool.decodeAt(data, pos);
            ++pos;
            if (hasCheckOrigin) {
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
        } else if (variant == InstructionVariant.PayFees) {
            pos += AssetCodec.encodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.InitiateTransfer) {
            pos += LocationCodec.encodedSizeAt(data, pos);
            bool hasRemoteFees = Bool.decodeAt(data, pos);
            ++pos;
            if (hasRemoteFees) {
                pos += AssetTransferFilterCodec.encodedSizeAt(data, pos);
            }
            ++pos; // preserveOrigin bool
            (uint256 assetsCount, uint256 assetsCountBytes) = Compact.decodeAt(
                data,
                pos
            );
            if (assetsCount > MAX_ASSET_TRANSFER_FILTERS) {
                revert InvalidInstructionPayload();
            }
            pos += assetsCountBytes;
            for (uint256 i = 0; i < assetsCount; ++i) {
                pos += AssetTransferFilterCodec.encodedSizeAt(data, pos);
            }
            (uint256 remoteXcmLen, uint256 remoteXcmLenBytes) = Compact
                .decodeAt(data, pos);
            pos += remoteXcmLenBytes;
            if (data.length < pos + remoteXcmLen)
                revert InvalidInstructionPayload();
            pos += remoteXcmLen;
        } else if (variant == InstructionVariant.ExecuteWithOrigin) {
            bool hasDescendantOrigin = Bool.decodeAt(data, pos);
            ++pos;
            if (hasDescendantOrigin) {
                pos += JunctionsCodec.encodedSizeAt(data, pos);
            }
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (variant == InstructionVariant.SetHints) {
            (uint256 hintsCount, uint256 hintsCountBytes) = Compact.decodeAt(
                data,
                pos
            );
            if (hintsCount > HINT_NUM_VARIANTS) {
                revert InvalidInstructionPayload();
            }
            pos += hintsCountBytes;
            for (uint256 i = 0; i < hintsCount; ++i) {
                pos += HintCodec.encodedSizeAt(data, pos);
            }
        }

        return pos - offset;
    }

    /// @notice Decodes an `Instruction` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded instruction.
    /// @return instruction The decoded `Instruction` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    )
        internal
        pure
        returns (Instruction memory instruction, uint256 bytesRead)
    {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `Instruction` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded instruction.
    /// @param offset The starting index in `data` from which to decode.
    /// @return instruction The decoded `Instruction` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    )
        internal
        pure
        returns (Instruction memory instruction, uint256 bytesRead)
    {
        uint256 size = encodedSizeAt(data, offset);
        uint8 variantRaw = uint8(data[offset]);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        instruction = Instruction({
            variant: InstructionVariant(variantRaw),
            payload: payload
        });
        bytesRead = size;
    }

    /// @notice Extracts the decoded `WithdrawAssetParams` from a `WithdrawAsset` instruction. Reverts if the instruction is not of type `WithdrawAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `WithdrawAsset`.
    /// @return params The decoded `WithdrawAssetParams` extracted from the instruction payload.
    function asWithdrawAsset(
        Instruction memory instruction
    ) internal pure returns (WithdrawAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.WithdrawAsset);
        uint256 bytesRead;
        (params.assets, bytesRead) = AssetsCodec.decode(instruction.payload);
    }

    /// @notice Extracts the decoded `ReserveAssetDepositedParams` from a `ReserveAssetDeposited` instruction. Reverts if the instruction is not of type `ReserveAssetDeposited`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ReserveAssetDeposited`.
    /// @return params The decoded `ReserveAssetDepositedParams` extracted from the instruction payload.
    function asReserveAssetDeposited(
        Instruction memory instruction
    ) internal pure returns (ReserveAssetDepositedParams memory params) {
        _assertVariant(instruction, InstructionVariant.ReserveAssetDeposited);
        uint256 bytesRead;
        (params.assets, bytesRead) = AssetsCodec.decode(instruction.payload);
    }

    /// @notice Extracts the decoded `ReceiveTeleportedAssetParams` from a `ReceiveTeleportedAsset` instruction. Reverts if the instruction is not of type `ReceiveTeleportedAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ReceiveTeleportedAsset`.
    /// @return params The decoded `ReceiveTeleportedAssetParams` extracted from the instruction payload.
    function asReceiveTeleportedAsset(
        Instruction memory instruction
    ) internal pure returns (ReceiveTeleportedAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.ReceiveTeleportedAsset);
        uint256 bytesRead;
        (params.assets, bytesRead) = AssetsCodec.decode(instruction.payload);
    }

    /// @notice Extracts the decoded `QueryResponseParams` from a `QueryResponse` instruction. Reverts if the instruction is not of type `QueryResponse`.
    /// @param instruction The `Instruction` struct to decode, which must have type `QueryResponse`.
    /// @return params The decoded `QueryResponseParams` extracted from the instruction payload.
    function asQueryResponse(
        Instruction memory instruction
    ) internal pure returns (QueryResponseParams memory params) {
        _assertVariant(instruction, InstructionVariant.QueryResponse);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 queryIdRaw;

        (queryIdRaw, bytesRead) = Compact.decodeAt(payload, pos);
        params.queryId = QueryId.wrap(UnsignedUtils.toU64(queryIdRaw));
        pos += bytesRead;

        (params.response, bytesRead) = ResponseCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.maxWeight, bytesRead) = WeightCodec.decodeAt(payload, pos);
        pos += bytesRead;

        params.hasQuerier = Bool.decodeAt(payload, pos);
        ++pos;

        if (params.hasQuerier) {
            (params.querier, bytesRead) = LocationCodec.decodeAt(payload, pos);
            pos += bytesRead;
        }
    }

    /// @notice Extracts the decoded `TransferAssetParams` from a `TransferAsset` instruction. Reverts if the instruction is not of type `TransferAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `TransferAsset`.
    /// @return params The decoded `TransferAssetParams` extracted from the instruction payload.
    function asTransferAsset(
        Instruction memory instruction
    ) internal pure returns (TransferAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.TransferAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.assets, bytesRead) = AssetsCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.beneficiary, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `TransferReserveAssetParams` from a `TransferReserveAsset` instruction. Reverts if the instruction is not of type `TransferReserveAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `TransferReserveAsset`.
    /// @return params The decoded `TransferReserveAssetParams` extracted from the instruction payload.
    function asTransferReserveAsset(
        Instruction memory instruction
    ) internal pure returns (TransferReserveAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.TransferReserveAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.assets, bytesRead) = AssetsCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.dest, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.xcm, pos) = _decodeXcmAt(payload, pos);
    }

    /// @notice Extracts the decoded `TransactParams` from a `Transact` instruction. Reverts if the instruction is not of type `Transact`.
    /// @param instruction The `Instruction` struct to decode, which must have type `Transact`.
    /// @return params The decoded `TransactParams` extracted from the instruction payload.
    function asTransact(
        Instruction memory instruction
    ) internal pure returns (TransactParams memory params) {
        _assertVariant(instruction, InstructionVariant.Transact);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.originKind, bytesRead) = OriginKindCodec.decodeAt(payload, pos);
        pos += bytesRead;

        params.hasFallbackMaxWeight = Bool.decodeAt(payload, pos);
        ++pos;

        if (params.hasFallbackMaxWeight) {
            (params.fallbackMaxWeight, bytesRead) = WeightCodec.decodeAt(
                payload,
                pos
            );
            pos += bytesRead;
        }

        (params.call, bytesRead) = Bytes.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `HrmpNewChannelOpenRequestParams` from a `HrmpNewChannelOpenRequest` instruction. Reverts if the instruction is not of type `HrmpNewChannelOpenRequest`.
    /// @param instruction The `Instruction` struct to decode, which must have type `HrmpNewChannelOpenRequest`.
    /// @return params The decoded `HrmpNewChannelOpenRequestParams` extracted from the instruction payload.
    function asHrmpNewChannelOpenRequest(
        Instruction memory instruction
    ) internal pure returns (HrmpNewChannelOpenRequestParams memory params) {
        _assertVariant(
            instruction,
            InstructionVariant.HrmpNewChannelOpenRequest
        );
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 value;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.sender = UnsignedUtils.toU32(value);
        pos += bytesRead;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.maxMessageSize = UnsignedUtils.toU32(value);
        pos += bytesRead;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.maxCapacity = UnsignedUtils.toU32(value);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `HrmpChannelAcceptedParams` from a `HrmpChannelAccepted` instruction. Reverts if the instruction is not of type `HrmpChannelAccepted`.
    /// @param instruction The `Instruction` struct to decode, which must have type `HrmpChannelAccepted`.
    /// @return params The decoded `HrmpChannelAcceptedParams` extracted from the instruction payload.
    function asHrmpChannelAccepted(
        Instruction memory instruction
    ) internal pure returns (HrmpChannelAcceptedParams memory params) {
        _assertVariant(instruction, InstructionVariant.HrmpChannelAccepted);
        uint256 value;
        uint256 bytesRead;
        (value, bytesRead) = Compact.decode(instruction.payload);
        params.recipient = UnsignedUtils.toU32(value);
    }

    /// @notice Extracts the decoded `HrmpChannelClosingParams` from a `HrmpChannelClosing` instruction. Reverts if the instruction is not of type `HrmpChannelClosing`.
    /// @param instruction The `Instruction` struct to decode, which must have type `HrmpChannelClosing`.
    /// @return params The decoded `HrmpChannelClosingParams` extracted from the instruction payload.
    function asHrmpChannelClosing(
        Instruction memory instruction
    ) internal pure returns (HrmpChannelClosingParams memory params) {
        _assertVariant(instruction, InstructionVariant.HrmpChannelClosing);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 value;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.initiator = UnsignedUtils.toU32(value);
        pos += bytesRead;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.sender = UnsignedUtils.toU32(value);
        pos += bytesRead;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.recipient = UnsignedUtils.toU32(value);
        pos += bytesRead;
    }

    /// @notice Validates a `ClearOrigin` instruction payload. Reverts if the instruction is not of type `ClearOrigin` or the payload is invalid.
    /// @param instruction The `Instruction` struct to validate, which must have type `ClearOrigin`.
    function asClearOrigin(Instruction memory instruction) internal pure {
        _assertVariant(instruction, InstructionVariant.ClearOrigin);
        if (instruction.payload.length != 0) revert InvalidInstructionPayload();
    }

    /// @notice Extracts the decoded `DescendOriginParams` from a `DescendOrigin` instruction. Reverts if the instruction is not of type `DescendOrigin`.
    /// @param instruction The `Instruction` struct to decode, which must have type `DescendOrigin`.
    /// @return params The decoded `DescendOriginParams` extracted from the instruction payload.
    function asDescendOrigin(
        Instruction memory instruction
    ) internal pure returns (DescendOriginParams memory params) {
        _assertVariant(instruction, InstructionVariant.DescendOrigin);
        uint256 bytesRead;
        (params.interior, bytesRead) = JunctionsCodec.decode(
            instruction.payload
        );
    }

    /// @notice Extracts the decoded `ReportErrorParams` from a `ReportError` instruction. Reverts if the instruction is not of type `ReportError`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ReportError`.
    /// @return params The decoded `ReportErrorParams` extracted from the instruction payload.
    function asReportError(
        Instruction memory instruction
    ) internal pure returns (ReportErrorParams memory params) {
        _assertVariant(instruction, InstructionVariant.ReportError);
        uint256 bytesRead;
        (params.responseInfo, bytesRead) = QueryResponseInfoCodec.decode(
            instruction.payload
        );
    }

    /// @notice Extracts the decoded `DepositAssetParams` from a `DepositAsset` instruction. Reverts if the instruction is not of type `DepositAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `DepositAsset`.
    /// @return params The decoded `DepositAssetParams` extracted from the instruction payload.
    function asDepositAsset(
        Instruction memory instruction
    ) internal pure returns (DepositAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.DepositAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.assets, bytesRead) = AssetFilterCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.beneficiary, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `DepositReserveAssetParams` from a `DepositReserveAsset` instruction. Reverts if the instruction is not of type `DepositReserveAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `DepositReserveAsset`.
    /// @return params The decoded `DepositReserveAssetParams` extracted from the instruction payload.
    function asDepositReserveAsset(
        Instruction memory instruction
    ) internal pure returns (DepositReserveAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.DepositReserveAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.assets, bytesRead) = AssetFilterCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.dest, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.xcm, pos) = _decodeXcmAt(payload, pos);
    }

    /// @notice Extracts the decoded `ExchangeAssetParams` from a `ExchangeAsset` instruction. Reverts if the instruction is not of type `ExchangeAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExchangeAsset`.
    /// @return params The decoded `ExchangeAssetParams` extracted from the instruction payload.
    function asExchangeAsset(
        Instruction memory instruction
    ) internal pure returns (ExchangeAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExchangeAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.give, bytesRead) = AssetFilterCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.want, bytesRead) = AssetsCodec.decodeAt(payload, pos);
        pos += bytesRead;

        params.maximal = Bool.decodeAt(payload, pos);
        ++pos;
    }

    /// @notice Extracts the decoded `InitiateReserveWithdrawParams` from a `InitiateReserveWithdraw` instruction. Reverts if the instruction is not of type `InitiateReserveWithdraw`.
    /// @param instruction The `Instruction` struct to decode, which must have type `InitiateReserveWithdraw`.
    /// @return params The decoded `InitiateReserveWithdrawParams` extracted from the instruction payload.
    function asInitiateReserveWithdraw(
        Instruction memory instruction
    ) internal pure returns (InitiateReserveWithdrawParams memory params) {
        _assertVariant(instruction, InstructionVariant.InitiateReserveWithdraw);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.assets, bytesRead) = AssetFilterCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.reserve, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.xcm, pos) = _decodeXcmAt(payload, pos);
    }

    /// @notice Extracts the decoded `InitiateTeleportParams` from a `InitiateTeleport` instruction. Reverts if the instruction is not of type `InitiateTeleport`.
    /// @param instruction The `Instruction` struct to decode, which must have type `InitiateTeleport`.
    /// @return params The decoded `InitiateTeleportParams` extracted from the instruction payload.
    function asInitiateTeleport(
        Instruction memory instruction
    ) internal pure returns (InitiateTeleportParams memory params) {
        _assertVariant(instruction, InstructionVariant.InitiateTeleport);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.assets, bytesRead) = AssetFilterCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.dest, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.xcm, pos) = _decodeXcmAt(payload, pos);
    }

    /// @notice Extracts the decoded `ReportHoldingParams` from a `ReportHolding` instruction. Reverts if the instruction is not of type `ReportHolding`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ReportHolding`.
    /// @return params The decoded `ReportHoldingParams` extracted from the instruction payload.
    function asReportHolding(
        Instruction memory instruction
    ) internal pure returns (ReportHoldingParams memory params) {
        _assertVariant(instruction, InstructionVariant.ReportHolding);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.responseInfo, bytesRead) = QueryResponseInfoCodec.decodeAt(
            payload,
            pos
        );
        pos += bytesRead;

        (params.assets, bytesRead) = AssetFilterCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `BuyExecutionParams` from a `BuyExecution` instruction. Reverts if the instruction is not of type `BuyExecution`.
    /// @param instruction The `Instruction` struct to decode, which must have type `BuyExecution`.
    /// @return params The decoded `BuyExecutionParams` extracted from the instruction payload.
    function asBuyExecution(
        Instruction memory instruction
    ) internal pure returns (BuyExecutionParams memory params) {
        _assertVariant(instruction, InstructionVariant.BuyExecution);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.fees, bytesRead) = AssetCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.weightLimit, bytesRead) = WeightLimitCodec.decodeAt(
            payload,
            pos
        );
        pos += bytesRead;
    }

    /// @notice Validates a `RefundSurplus` instruction payload. Reverts if the instruction is not of type `RefundSurplus` or the payload is invalid.
    /// @param instruction The `Instruction` struct to validate, which must have type `RefundSurplus`.
    function asRefundSurplus(Instruction memory instruction) internal pure {
        _assertVariant(instruction, InstructionVariant.RefundSurplus);
        if (instruction.payload.length != 0) revert InvalidInstructionPayload();
    }

    /// @notice Extracts the decoded `SetErrorHandlerParams` from a `SetErrorHandler` instruction. Reverts if the instruction is not of type `SetErrorHandler`.
    /// @param instruction The `Instruction` struct to decode, which must have type `SetErrorHandler`.
    /// @return params The decoded `SetErrorHandlerParams` extracted from the instruction payload.
    function asSetErrorHandler(
        Instruction memory instruction
    ) internal pure returns (SetErrorHandlerParams memory params) {
        _assertVariant(instruction, InstructionVariant.SetErrorHandler);
        (params.xcm, ) = _decodeXcmAt(instruction.payload, 0);
    }

    /// @notice Extracts the decoded `SetAppendixParams` from a `SetAppendix` instruction. Reverts if the instruction is not of type `SetAppendix`.
    /// @param instruction The `Instruction` struct to decode, which must have type `SetAppendix`.
    /// @return params The decoded `SetAppendixParams` extracted from the instruction payload.
    function asSetAppendix(
        Instruction memory instruction
    ) internal pure returns (SetAppendixParams memory params) {
        _assertVariant(instruction, InstructionVariant.SetAppendix);
        (params.xcm, ) = _decodeXcmAt(instruction.payload, 0);
    }

    /// @notice Validates a `ClearError` instruction payload. Reverts if the instruction is not of type `ClearError` or the payload is invalid.
    /// @param instruction The `Instruction` struct to validate, which must have type `ClearError`.
    function asClearError(Instruction memory instruction) internal pure {
        _assertVariant(instruction, InstructionVariant.ClearError);
        if (instruction.payload.length != 0) revert InvalidInstructionPayload();
    }

    /// @notice Extracts the decoded `ClaimAssetParams` from a `ClaimAsset` instruction. Reverts if the instruction is not of type `ClaimAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ClaimAsset`.
    /// @return params The decoded `ClaimAssetParams` extracted from the instruction payload.
    function asClaimAsset(
        Instruction memory instruction
    ) internal pure returns (ClaimAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.ClaimAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.assets, bytesRead) = AssetsCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.ticket, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `TrapParams` from a `Trap` instruction. Reverts if the instruction is not of type `Trap`.
    /// @param instruction The `Instruction` struct to decode, which must have type `Trap`.
    /// @return params The decoded `TrapParams` extracted from the instruction payload.
    function asTrap(
        Instruction memory instruction
    ) internal pure returns (TrapParams memory params) {
        _assertVariant(instruction, InstructionVariant.Trap);
        uint256 value;
        uint256 bytesRead;
        (value, bytesRead) = Compact.decode(instruction.payload);
        params.code = UnsignedUtils.toU64(value);
    }

    /// @notice Extracts the decoded `SubscribeVersionParams` from a `SubscribeVersion` instruction. Reverts if the instruction is not of type `SubscribeVersion`.
    /// @param instruction The `Instruction` struct to decode, which must have type `SubscribeVersion`.
    /// @return params The decoded `SubscribeVersionParams` extracted from the instruction payload.
    function asSubscribeVersion(
        Instruction memory instruction
    ) internal pure returns (SubscribeVersionParams memory params) {
        _assertVariant(instruction, InstructionVariant.SubscribeVersion);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 queryIdRaw;

        (queryIdRaw, bytesRead) = Compact.decodeAt(payload, pos);
        params.queryId = QueryId.wrap(UnsignedUtils.toU64(queryIdRaw));
        pos += bytesRead;

        (params.maxResponseWeight, bytesRead) = WeightCodec.decodeAt(
            payload,
            pos
        );
        pos += bytesRead;
    }

    /// @notice Validates a `UnsubscribeVersion` instruction payload. Reverts if the instruction is not of type `UnsubscribeVersion` or the payload is invalid.
    /// @param instruction The `Instruction` struct to validate, which must have type `UnsubscribeVersion`.
    function asUnsubscribeVersion(
        Instruction memory instruction
    ) internal pure {
        _assertVariant(instruction, InstructionVariant.UnsubscribeVersion);
        if (instruction.payload.length != 0) revert InvalidInstructionPayload();
    }

    /// @notice Extracts the decoded `BurnAssetParams` from a `BurnAsset` instruction. Reverts if the instruction is not of type `BurnAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `BurnAsset`.
    /// @return params The decoded `BurnAssetParams` extracted from the instruction payload.
    function asBurnAsset(
        Instruction memory instruction
    ) internal pure returns (BurnAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.BurnAsset);
        uint256 bytesRead;
        (params.assets, bytesRead) = AssetsCodec.decode(instruction.payload);
    }

    /// @notice Extracts the decoded `ExpectAssetParams` from a `ExpectAsset` instruction. Reverts if the instruction is not of type `ExpectAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExpectAsset`.
    /// @return params The decoded `ExpectAssetParams` extracted from the instruction payload.
    function asExpectAsset(
        Instruction memory instruction
    ) internal pure returns (ExpectAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExpectAsset);
        uint256 bytesRead;
        (params.assets, bytesRead) = AssetsCodec.decode(instruction.payload);
    }

    /// @notice Extracts the decoded `ExpectOriginParams` from a `ExpectOrigin` instruction. Reverts if the instruction is not of type `ExpectOrigin`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExpectOrigin`.
    /// @return params The decoded `ExpectOriginParams` extracted from the instruction payload.
    function asExpectOrigin(
        Instruction memory instruction
    ) internal pure returns (ExpectOriginParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExpectOrigin);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        params.hasOrigin = Bool.decodeAt(payload, pos);
        ++pos;

        if (params.hasOrigin) {
            (params.origin, bytesRead) = LocationCodec.decodeAt(payload, pos);
            pos += bytesRead;
        }
    }

    /// @notice Extracts the decoded `ExpectErrorParams` from a `ExpectError` instruction. Reverts if the instruction is not of type `ExpectError`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExpectError`.
    /// @return params The decoded `ExpectErrorParams` extracted from the instruction payload.
    function asExpectError(
        Instruction memory instruction
    ) internal pure returns (ExpectErrorParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExpectError);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 value;

        params.hasError = Bool.decodeAt(payload, pos);
        ++pos;

        if (params.hasError) {
            (value, bytesRead) = Compact.decodeAt(payload, pos);
            params.index = UnsignedUtils.toU32(value);
            pos += bytesRead;

            (params.err, bytesRead) = XcmErrorCodec.decodeAt(payload, pos);
            pos += bytesRead;
        }
    }

    /// @notice Extracts the decoded `ExpectTransactStatusParams` from a `ExpectTransactStatus` instruction. Reverts if the instruction is not of type `ExpectTransactStatus`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExpectTransactStatus`.
    /// @return params The decoded `ExpectTransactStatusParams` extracted from the instruction payload.
    function asExpectTransactStatus(
        Instruction memory instruction
    ) internal pure returns (ExpectTransactStatusParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExpectTransactStatus);
        uint256 bytesRead;
        (params.transactStatus, bytesRead) = MaybeErrorCodeCodec.decode(
            instruction.payload
        );
    }

    /// @notice Extracts the decoded `QueryPalletParams` from a `QueryPallet` instruction. Reverts if the instruction is not of type `QueryPallet`.
    /// @param instruction The `Instruction` struct to decode, which must have type `QueryPallet`.
    /// @return params The decoded `QueryPalletParams` extracted from the instruction payload.
    function asQueryPallet(
        Instruction memory instruction
    ) internal pure returns (QueryPalletParams memory params) {
        _assertVariant(instruction, InstructionVariant.QueryPallet);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.moduleName, bytesRead) = Bytes.decodeAt(payload, pos);
        pos += bytesRead;

        (params.responseInfo, bytesRead) = QueryResponseInfoCodec.decodeAt(
            payload,
            pos
        );
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `ExpectPalletParams` from a `ExpectPallet` instruction. Reverts if the instruction is not of type `ExpectPallet`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExpectPallet`.
    /// @return params The decoded `ExpectPalletParams` extracted from the instruction payload.
    function asExpectPallet(
        Instruction memory instruction
    ) internal pure returns (ExpectPalletParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExpectPallet);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 value;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.index = UnsignedUtils.toU32(value);
        pos += bytesRead;

        (params.name, bytesRead) = Bytes.decodeAt(payload, pos);
        pos += bytesRead;

        (params.moduleName, bytesRead) = Bytes.decodeAt(payload, pos);
        pos += bytesRead;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.crateMajor = UnsignedUtils.toU32(value);
        pos += bytesRead;

        (value, bytesRead) = Compact.decodeAt(payload, pos);
        params.minCrateMinor = UnsignedUtils.toU32(value);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `ReportTransactStatusParams` from a `ReportTransactStatus` instruction. Reverts if the instruction is not of type `ReportTransactStatus`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ReportTransactStatus`.
    /// @return params The decoded `ReportTransactStatusParams` extracted from the instruction payload.
    function asReportTransactStatus(
        Instruction memory instruction
    ) internal pure returns (ReportTransactStatusParams memory params) {
        _assertVariant(instruction, InstructionVariant.ReportTransactStatus);
        uint256 bytesRead;
        (params.responseInfo, bytesRead) = QueryResponseInfoCodec.decode(
            instruction.payload
        );
    }

    /// @notice Validates a `ClearTransactStatus` instruction payload. Reverts if the instruction is not of type `ClearTransactStatus` or the payload is invalid.
    /// @param instruction The `Instruction` struct to validate, which must have type `ClearTransactStatus`.
    function asClearTransactStatus(
        Instruction memory instruction
    ) internal pure {
        _assertVariant(instruction, InstructionVariant.ClearTransactStatus);
        if (instruction.payload.length != 0) revert InvalidInstructionPayload();
    }

    /// @notice Extracts the decoded `UniversalOriginParams` from a `UniversalOrigin` instruction. Reverts if the instruction is not of type `UniversalOrigin`.
    /// @param instruction The `Instruction` struct to decode, which must have type `UniversalOrigin`.
    /// @return params The decoded `UniversalOriginParams` extracted from the instruction payload.
    function asUniversalOrigin(
        Instruction memory instruction
    ) internal pure returns (UniversalOriginParams memory params) {
        _assertVariant(instruction, InstructionVariant.UniversalOrigin);
        uint256 bytesRead;
        (params.junction, bytesRead) = JunctionCodec.decode(
            instruction.payload
        );
    }

    /// @notice Extracts the decoded `ExportMessageParams` from a `ExportMessage` instruction. Reverts if the instruction is not of type `ExportMessage`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExportMessage`.
    /// @return params The decoded `ExportMessageParams` extracted from the instruction payload.
    function asExportMessage(
        Instruction memory instruction
    ) internal pure returns (ExportMessageParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExportMessage);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.network, bytesRead) = NetworkIdCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.destination, bytesRead) = JunctionsCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.xcm, pos) = _decodeXcmAt(payload, pos);
    }

    /// @notice Extracts the decoded `LockAssetParams` from a `LockAsset` instruction. Reverts if the instruction is not of type `LockAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `LockAsset`.
    /// @return params The decoded `LockAssetParams` extracted from the instruction payload.
    function asLockAsset(
        Instruction memory instruction
    ) internal pure returns (LockAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.LockAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.asset, bytesRead) = AssetCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.unlocker, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `UnlockAssetParams` from a `UnlockAsset` instruction. Reverts if the instruction is not of type `UnlockAsset`.
    /// @param instruction The `Instruction` struct to decode, which must have type `UnlockAsset`.
    /// @return params The decoded `UnlockAssetParams` extracted from the instruction payload.
    function asUnlockAsset(
        Instruction memory instruction
    ) internal pure returns (UnlockAssetParams memory params) {
        _assertVariant(instruction, InstructionVariant.UnlockAsset);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.asset, bytesRead) = AssetCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.target, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `NoteUnlockableParams` from a `NoteUnlockable` instruction. Reverts if the instruction is not of type `NoteUnlockable`.
    /// @param instruction The `Instruction` struct to decode, which must have type `NoteUnlockable`.
    /// @return params The decoded `NoteUnlockableParams` extracted from the instruction payload.
    function asNoteUnlockable(
        Instruction memory instruction
    ) internal pure returns (NoteUnlockableParams memory params) {
        _assertVariant(instruction, InstructionVariant.NoteUnlockable);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.asset, bytesRead) = AssetCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.owner, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `RequestUnlockParams` from a `RequestUnlock` instruction. Reverts if the instruction is not of type `RequestUnlock`.
    /// @param instruction The `Instruction` struct to decode, which must have type `RequestUnlock`.
    /// @return params The decoded `RequestUnlockParams` extracted from the instruction payload.
    function asRequestUnlock(
        Instruction memory instruction
    ) internal pure returns (RequestUnlockParams memory params) {
        _assertVariant(instruction, InstructionVariant.RequestUnlock);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.asset, bytesRead) = AssetCodec.decodeAt(payload, pos);
        pos += bytesRead;

        (params.locker, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `SetFeesModeParams` from a `SetFeesMode` instruction. Reverts if the instruction is not of type `SetFeesMode`.
    /// @param instruction The `Instruction` struct to decode, which must have type `SetFeesMode`.
    /// @return params The decoded `SetFeesModeParams` extracted from the instruction payload.
    function asSetFeesMode(
        Instruction memory instruction
    ) internal pure returns (SetFeesModeParams memory params) {
        _assertVariant(instruction, InstructionVariant.SetFeesMode);
        if (instruction.payload.length != 1) revert InvalidInstructionPayload();
        params.jitWithdraw = Bool.decode(instruction.payload);
    }

    /// @notice Extracts the decoded `SetTopicParams` from a `SetTopic` instruction. Reverts if the instruction is not of type `SetTopic`.
    /// @param instruction The `Instruction` struct to decode, which must have type `SetTopic`.
    /// @return params The decoded `SetTopicParams` extracted from the instruction payload.
    function asSetTopic(
        Instruction memory instruction
    ) internal pure returns (SetTopicParams memory params) {
        _assertVariant(instruction, InstructionVariant.SetTopic);
        if (instruction.payload.length != 32)
            revert InvalidInstructionPayload();
        params.topic = Bytes32.decode(instruction.payload);
    }

    /// @notice Validates a `ClearTopic` instruction payload. Reverts if the instruction is not of type `ClearTopic` or the payload is invalid.
    /// @param instruction The `Instruction` struct to validate, which must have type `ClearTopic`.
    function asClearTopic(Instruction memory instruction) internal pure {
        _assertVariant(instruction, InstructionVariant.ClearTopic);
        if (instruction.payload.length != 0) revert InvalidInstructionPayload();
    }

    /// @notice Extracts the decoded `AliasOriginParams` from a `AliasOrigin` instruction. Reverts if the instruction is not of type `AliasOrigin`.
    /// @param instruction The `Instruction` struct to decode, which must have type `AliasOrigin`.
    /// @return params The decoded `AliasOriginParams` extracted from the instruction payload.
    function asAliasOrigin(
        Instruction memory instruction
    ) internal pure returns (AliasOriginParams memory params) {
        _assertVariant(instruction, InstructionVariant.AliasOrigin);
        uint256 bytesRead;
        (params.location, bytesRead) = LocationCodec.decode(
            instruction.payload
        );
    }

    /// @notice Extracts the decoded `UnpaidExecutionParams` from a `UnpaidExecution` instruction. Reverts if the instruction is not of type `UnpaidExecution`.
    /// @param instruction The `Instruction` struct to decode, which must have type `UnpaidExecution`.
    /// @return params The decoded `UnpaidExecutionParams` extracted from the instruction payload.
    function asUnpaidExecution(
        Instruction memory instruction
    ) internal pure returns (UnpaidExecutionParams memory params) {
        _assertVariant(instruction, InstructionVariant.UnpaidExecution);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        (params.weightLimit, bytesRead) = WeightLimitCodec.decodeAt(
            payload,
            pos
        );
        pos += bytesRead;

        params.hasCheckOrigin = Bool.decodeAt(payload, pos);
        ++pos;

        if (params.hasCheckOrigin) {
            (params.checkOrigin, bytesRead) = LocationCodec.decodeAt(
                payload,
                pos
            );
            pos += bytesRead;
        }
    }

    /// @notice Extracts the decoded `PayFeesParams` from a `PayFees` instruction. Reverts if the instruction is not of type `PayFees`.
    /// @param instruction The `Instruction` struct to decode, which must have type `PayFees`.
    /// @return params The decoded `PayFeesParams` extracted from the instruction payload.
    function asPayFees(
        Instruction memory instruction
    ) internal pure returns (PayFeesParams memory params) {
        _assertVariant(instruction, InstructionVariant.PayFees);
        uint256 bytesRead;
        (params.asset, bytesRead) = AssetCodec.decode(instruction.payload);
    }

    /// @notice Extracts the decoded `InitiateTransferParams` from a `InitiateTransfer` instruction. Reverts if the instruction is not of type `InitiateTransfer`.
    /// @param instruction The `Instruction` struct to decode, which must have type `InitiateTransfer`.
    /// @return params The decoded `InitiateTransferParams` extracted from the instruction payload.
    function asInitiateTransfer(
        Instruction memory instruction
    ) internal pure returns (InitiateTransferParams memory params) {
        _assertVariant(instruction, InstructionVariant.InitiateTransfer);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 assetsCount;

        (params.destination, bytesRead) = LocationCodec.decodeAt(payload, pos);
        pos += bytesRead;

        params.hasRemoteFees = Bool.decodeAt(payload, pos);
        ++pos;

        if (params.hasRemoteFees) {
            (params.remoteFees, bytesRead) = AssetTransferFilterCodec.decodeAt(
                payload,
                pos
            );
            pos += bytesRead;
        }

        params.preserveOrigin = Bool.decodeAt(payload, pos);
        ++pos;

        (assetsCount, bytesRead) = Compact.decodeAt(payload, pos);
        if (assetsCount > MAX_ASSET_TRANSFER_FILTERS) {
            revert InvalidInstructionPayload();
        }
        pos += bytesRead;

        params.assets = new AssetTransferFilter[](assetsCount);
        for (uint256 i = 0; i < assetsCount; ++i) {
            (params.assets[i], bytesRead) = AssetTransferFilterCodec.decodeAt(
                payload,
                pos
            );
            pos += bytesRead;
        }

        (params.remoteXcm, bytesRead) = Bytes.decodeAt(payload, pos);
        pos += bytesRead;
    }

    /// @notice Extracts the decoded `ExecuteWithOriginParams` from a `ExecuteWithOrigin` instruction. Reverts if the instruction is not of type `ExecuteWithOrigin`.
    /// @param instruction The `Instruction` struct to decode, which must have type `ExecuteWithOrigin`.
    /// @return params The decoded `ExecuteWithOriginParams` extracted from the instruction payload.
    function asExecuteWithOrigin(
        Instruction memory instruction
    ) internal pure returns (ExecuteWithOriginParams memory params) {
        _assertVariant(instruction, InstructionVariant.ExecuteWithOrigin);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;

        params.hasDescendantOrigin = Bool.decodeAt(payload, pos);
        ++pos;

        if (params.hasDescendantOrigin) {
            (params.descendantOrigin, bytesRead) = JunctionsCodec.decodeAt(
                payload,
                pos
            );
            pos += bytesRead;
        }

        (params.xcm, pos) = _decodeXcmAt(payload, pos);
    }

    /// @notice Extracts the decoded `SetHintsParams` from a `SetHints` instruction. Reverts if the instruction is not of type `SetHints`.
    /// @param instruction The `Instruction` struct to decode, which must have type `SetHints`.
    /// @return params The decoded `SetHintsParams` extracted from the instruction payload.
    function asSetHints(
        Instruction memory instruction
    ) internal pure returns (SetHintsParams memory params) {
        _assertVariant(instruction, InstructionVariant.SetHints);
        bytes memory payload = instruction.payload;
        uint256 pos;
        uint256 bytesRead;
        uint256 hintsCount;

        (hintsCount, bytesRead) = Compact.decodeAt(payload, pos);
        if (hintsCount > HINT_NUM_VARIANTS) {
            revert InvalidInstructionPayload();
        }
        pos += bytesRead;

        params.hints = new Hint[](hintsCount);
        for (uint256 i = 0; i < hintsCount; ++i) {
            (params.hints[i], bytesRead) = HintCodec.decodeAt(payload, pos);
            pos += bytesRead;
        }
    }

    /// @notice Returns the encoded size of an XCM byte sequence at offset.
    /// @dev XCM encodes as `Vec<Instruction>`: compact count followed by encoded instructions.
    /// @param data The byte sequence containing encoded XCM.
    /// @param offset The starting index in `data` from which to calculate size.
    /// @return The number of bytes occupied by the XCM sequence starting at `offset`.
    function _xcmEncodedSizeAt(
        bytes memory data,
        uint256 offset
    ) private pure returns (uint256) {
        (uint256 count, uint256 countBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + countBytes;
        for (uint256 i = 0; i < count; ++i) {
            pos += encodedSizeAt(data, pos);
        }
        return pos - offset;
    }

    function _assertVariant(
        Instruction memory instruction,
        InstructionVariant expectedType
    ) private pure {
        if (instruction.variant != expectedType) {
            revert InvalidInstructionVariant(uint8(instruction.variant));
        }
    }

    function _decodeXcmAt(
        bytes memory payload,
        uint256 offset
    ) private pure returns (bytes memory xcm, uint256 nextOffset) {
        uint256 xcmLength = _xcmEncodedSizeAt(payload, offset);
        xcm = BytesUtils.copy(payload, offset, xcmLength);
        nextOffset = offset + xcmLength;
    }
}
