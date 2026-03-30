// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Instruction, InstructionType} from "./Instruction.sol";
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
import {Bytes} from "../../../Scale/Bytes/Bytes.sol";

/// @title SCALE Codec for XCM v5 `Instruction`
/// @notice SCALE-compliant encoder/decoder for the `Instruction` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library InstructionCodec {
    error InvalidInstructionLength();
    error InvalidInstructionType(uint8 iType);
    error InvalidInstructionPayload();

    /// @notice Encodes an `Instruction` into SCALE bytes.
    /// @param instruction The `Instruction` struct to encode.
    /// @return SCALE-encoded bytes representing the instruction.
    function encode(
        Instruction memory instruction
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(instruction.iType), instruction.payload);
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

        uint8 iTypeRaw = uint8(data[offset]);
        if (iTypeRaw > uint8(InstructionType.SetHints)) {
            revert InvalidInstructionType(iTypeRaw);
        }

        InstructionType iType = InstructionType(iTypeRaw);
        uint256 pos = offset + 1;

        if (
            iType == InstructionType.WithdrawAsset ||
            iType == InstructionType.ReserveAssetDeposited ||
            iType == InstructionType.ReceiveTeleportedAsset ||
            iType == InstructionType.BurnAsset ||
            iType == InstructionType.ExpectAsset
        ) {
            pos += AssetsCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.QueryResponse) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += ResponseCodec.encodedSizeAt(data, pos);
            pos += WeightCodec.encodedSizeAt(data, pos);
            bool hasQuerier = Bool.decodeAt(data, pos);
            pos += 1;
            if (hasQuerier) {
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
        } else if (iType == InstructionType.TransferAsset) {
            pos += AssetsCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (
            iType == InstructionType.TransferReserveAsset ||
            iType == InstructionType.DepositReserveAsset ||
            iType == InstructionType.InitiateReserveWithdraw ||
            iType == InstructionType.InitiateTeleport
        ) {
            if (iType == InstructionType.TransferReserveAsset) {
                pos += AssetsCodec.encodedSizeAt(data, pos);
                pos += LocationCodec.encodedSizeAt(data, pos);
            } else {
                pos += AssetFilterCodec.encodedSizeAt(data, pos);
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (iType == InstructionType.Transact) {
            pos += OriginKindCodec.encodedSizeAt(data, pos);
            bool hasFallbackMaxWeight = Bool.decodeAt(data, pos);
            pos += 1;
            if (hasFallbackMaxWeight) {
                pos += WeightCodec.encodedSizeAt(data, pos);
            }
            pos += Bytes.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.HrmpNewChannelOpenRequest) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.HrmpChannelAccepted) {
            pos += Compact.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.HrmpChannelClosing) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
        } else if (
            iType == InstructionType.ClearOrigin ||
            iType == InstructionType.RefundSurplus ||
            iType == InstructionType.ClearError ||
            iType == InstructionType.UnsubscribeVersion ||
            iType == InstructionType.ClearTransactStatus ||
            iType == InstructionType.ClearTopic
        ) {
            // no payload
        } else if (iType == InstructionType.DescendOrigin) {
            pos += JunctionsCodec.encodedSizeAt(data, pos);
        } else if (
            iType == InstructionType.ReportError ||
            iType == InstructionType.ReportTransactStatus
        ) {
            pos += QueryResponseInfoCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.DepositAsset) {
            pos += AssetFilterCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.ExchangeAsset) {
            pos += AssetFilterCodec.encodedSizeAt(data, pos);
            pos += AssetsCodec.encodedSizeAt(data, pos);
            pos += 1;
        } else if (iType == InstructionType.ReportHolding) {
            pos += QueryResponseInfoCodec.encodedSizeAt(data, pos);
            pos += AssetFilterCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.BuyExecution) {
            pos += AssetCodec.encodedSizeAt(data, pos);
            pos += WeightLimitCodec.encodedSizeAt(data, pos);
        } else if (
            iType == InstructionType.SetErrorHandler ||
            iType == InstructionType.SetAppendix
        ) {
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (iType == InstructionType.ClaimAsset) {
            pos += AssetsCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.Trap) {
            pos += Compact.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.SubscribeVersion) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += WeightCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.ExpectOrigin) {
            bool hasOrigin = Bool.decodeAt(data, pos);
            pos += 1;
            if (hasOrigin) {
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
        } else if (iType == InstructionType.ExpectError) {
            bool hasError = Bool.decodeAt(data, pos);
            pos += 1;
            if (hasError) {
                pos += Compact.encodedSizeAt(data, pos);
                pos += XcmErrorCodec.encodedSizeAt(data, pos);
            }
        } else if (iType == InstructionType.ExpectTransactStatus) {
            pos += MaybeErrorCodeCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.QueryPallet) {
            pos += Bytes.encodedSizeAt(data, pos);
            pos += QueryResponseInfoCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.ExpectPallet) {
            pos += Compact.encodedSizeAt(data, pos);
            pos += Bytes.encodedSizeAt(data, pos);
            pos += Bytes.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
            pos += Compact.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.UniversalOrigin) {
            pos += JunctionCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.ExportMessage) {
            pos += NetworkIdCodec.encodedSizeAt(data, pos);
            pos += JunctionsCodec.encodedSizeAt(data, pos);
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (
            iType == InstructionType.LockAsset ||
            iType == InstructionType.UnlockAsset ||
            iType == InstructionType.NoteUnlockable ||
            iType == InstructionType.RequestUnlock
        ) {
            pos += AssetCodec.encodedSizeAt(data, pos);
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.SetFeesMode) {
            pos += 1;
        } else if (iType == InstructionType.SetTopic) {
            if (data.length < pos + 32) revert InvalidInstructionPayload();
            pos += 32;
        } else if (iType == InstructionType.AliasOrigin) {
            pos += LocationCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.UnpaidExecution) {
            pos += WeightLimitCodec.encodedSizeAt(data, pos);
            bool hasCheckOrigin = Bool.decodeAt(data, pos);
            pos += 1;
            if (hasCheckOrigin) {
                pos += LocationCodec.encodedSizeAt(data, pos);
            }
        } else if (iType == InstructionType.PayFees) {
            pos += AssetCodec.encodedSizeAt(data, pos);
        } else if (iType == InstructionType.InitiateTransfer) {
            pos += LocationCodec.encodedSizeAt(data, pos);
            bool hasRemoteFees = Bool.decodeAt(data, pos);
            pos += 1;
            if (hasRemoteFees) {
                pos += AssetTransferFilterCodec.encodedSizeAt(data, pos);
            }
            pos += 1; // preserveOrigin bool
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
        } else if (iType == InstructionType.ExecuteWithOrigin) {
            bool hasDescendantOrigin = Bool.decodeAt(data, pos);
            pos += 1;
            if (hasDescendantOrigin) {
                pos += JunctionsCodec.encodedSizeAt(data, pos);
            }
            pos += _xcmEncodedSizeAt(data, pos);
        } else if (iType == InstructionType.SetHints) {
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
        if (data.length < offset + 1) revert InvalidInstructionLength();

        uint8 iTypeRaw = uint8(data[offset]);
        if (iTypeRaw > uint8(InstructionType.SetHints)) {
            revert InvalidInstructionType(iTypeRaw);
        }

        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; ++i) {
            payload[i] = data[offset + 1 + i];
        }

        instruction = Instruction({
            iType: InstructionType(iTypeRaw),
            payload: payload
        });
        bytesRead = size;
    }

    /// @notice Returns the encoded size of an XCM byte sequence at offset.
    /// @dev XCM encodes as `Vec<Instruction>`: compact count followed by encoded instructions.
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
}
