// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Instruction, InstructionVariant, withdrawAsset, reserveAssetDeposited, receiveTeleportedAsset, queryResponse, transferAsset, transferReserveAsset, clearOrigin, descendOrigin, reportError, depositAsset, depositReserveAsset, exchangeAsset, initiateReserveWithdraw, initiateTeleport, reportHolding, buyExecution, refundSurplus, setErrorHandler, setAppendix, clearError, claimAsset, trap, subscribeVersion, unsubscribeVersion, burnAsset, expectAsset, expectOrigin, expectError, expectTransactStatus, queryPallet, expectPallet, reportTransactStatus, clearTransactStatus, universalOrigin, exportMessage, lockAsset, unlockAsset, noteUnlockable, requestUnlock, setFeesMode, setTopic, clearTopic, aliasOrigin, unpaidExecution, payFees, initiateTransfer, executeWithOrigin, setHints, WithdrawAssetParams, ReserveAssetDepositedParams, ReceiveTeleportedAssetParams, QueryResponseParams, TransferAssetParams, TransferReserveAssetParams, HrmpNewChannelOpenRequestParams, HrmpChannelAcceptedParams, HrmpChannelClosingParams, DescendOriginParams, ReportErrorParams, DepositAssetParams, DepositReserveAssetParams, ExchangeAssetParams, InitiateReserveWithdrawParams, InitiateTeleportParams, ReportHoldingParams, BuyExecutionParams, SetErrorHandlerParams, SetAppendixParams, ClaimAssetParams, TrapParams, SubscribeVersionParams, BurnAssetParams, ExpectAssetParams, ExpectOriginParams, ExpectErrorParams, ExpectTransactStatusParams, QueryPalletParams, ExpectPalletParams, ReportTransactStatusParams, UniversalOriginParams, ExportMessageParams, LockAssetParams, UnlockAssetParams, NoteUnlockableParams, RequestUnlockParams, SetFeesModeParams, SetTopicParams, AliasOriginParams, UnpaidExecutionParams, PayFeesParams, InitiateTransferParams, ExecuteWithOriginParams, SetHintsParams, transact, TransactParams} from "../../../src/Xcm/v5/Instruction/Instruction.sol";
import {InstructionCodec as Codec} from "../../../src/Xcm/v5/Instruction/InstructionCodec.sol";
import {Assets} from "../../../src/Xcm/v5/Assets/Assets.sol";
import {Asset} from "../../../src/Xcm/v5/Asset/Asset.sol";
import {AssetId} from "../../../src/Xcm/v5/AssetId/AssetId.sol";
import {Fungibility, fungible, FungibleParams} from "../../../src/Xcm/v5/Fungibility/Fungibility.sol";
import {Location, parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {Junctions, here} from "../../../src/Xcm/v5/Junctions/Junctions.sol";
import {AssetFilter, wild, WildParams} from "../../../src/Xcm/v5/AssetFilter/AssetFilter.sol";
import {WildAsset, all} from "../../../src/Xcm/v5/WildAsset/WildAsset.sol";
import {Response, null_} from "../../../src/Xcm/v5/Response/Response.sol";
import {Weight, fromParts} from "../../../src/Xcm/v5/Weight/Weight.sol";
import {WeightLimit, unlimited} from "../../../src/Xcm/v5/WeightLimit/WeightLimit.sol";
import {Asset as AssetType} from "../../../src/Xcm/v5/Asset/Asset.sol";
import {QueryId} from "../../../src/Xcm/v5/Types/QueryId.sol";
import {QueryResponseInfo} from "../../../src/Xcm/v5/QueryResponseInfo/QueryResponseInfo.sol";
import {Hint, assetClaimer, AssetClaimerParams} from "../../../src/Xcm/v5/Hint/Hint.sol";
import {XcmError, XcmErrorVariant} from "../../../src/Xcm/v5/XcmError/XcmError.sol";
import {MaybeErrorCode, MaybeErrorCodeVariant} from "../../../src/Xcm/v3/MaybeErrorCode/MaybeErrorCode.sol";
import {OriginKind} from "../../../src/Xcm/v5/OriginKind/OriginKind.sol";
import {Test} from "forge-std/Test.sol";

contract InstructionWrapper {
    function decode(
        bytes memory data
    ) external pure returns (Instruction memory) {
        (Instruction memory result, ) = Codec.decode(data);
        return result;
    }
}

contract InstructionTest is Test {
    InstructionWrapper private wrapper;

    function setUp() public {
        wrapper = new InstructionWrapper();
    }

    function _assertRoundTrip(
        Instruction memory instr,
        bytes memory expected
    ) internal view {
        bytes memory encoded = Codec.encode(instr);
        assertEq(encoded, expected);
        Instruction memory decoded = wrapper.decode(expected);
        assertEq(keccak256(abi.encode(instr)), keccak256(abi.encode(decoded)));
    }

    // 0: WithdrawAsset
    // Encoder: 0000
    function testWithdrawAsset() public view {
        Assets memory emptyAssets;
        _assertRoundTrip(
            withdrawAsset(WithdrawAssetParams({assets: emptyAssets})),
            hex"0000"
        );
    }

    // 1: ReserveAssetDeposited
    // Encoder: 0100
    function testReserveAssetDeposited() public view {
        Assets memory emptyAssets;
        _assertRoundTrip(
            reserveAssetDeposited(
                ReserveAssetDepositedParams({assets: emptyAssets})
            ),
            hex"0100"
        );
    }

    // 2: ReceiveTeleportedAsset
    // Encoder: 0200
    function testReceiveTeleportedAsset() public view {
        Assets memory emptyAssets;
        _assertRoundTrip(
            receiveTeleportedAsset(
                ReceiveTeleportedAssetParams({assets: emptyAssets})
            ),
            hex"0200"
        );
    }

    // 3: QueryResponse (None querier)
    // Encoder: 030000000000
    function testQueryResponse() public view {
        _assertRoundTrip(
            queryResponse(
                QueryResponseParams({
                    queryId: QueryId.wrap(0),
                    response: null_(),
                    maxWeight: fromParts(0, 0),
                    hasQuerier: false,
                    querier: Location({parents: 0, interior: here()})
                })
            ),
            hex"030000000000"
        );
    }

    // 4: TransferAsset
    // Encoder: 04000000
    function testTransferAsset() public view {
        Assets memory emptyAssets;
        Location memory emptyLocation = Location({
            parents: 0,
            interior: here()
        });
        _assertRoundTrip(
            transferAsset(
                TransferAssetParams({
                    assets: emptyAssets,
                    beneficiary: emptyLocation
                })
            ),
            hex"04000000"
        );
    }

    // 5: TransferReserveAsset
    // Encoder: 0500000000
    function testTransferReserveAsset() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.TransferReserveAsset,
                payload: hex"00000000"
            }),
            hex"0500000000"
        );
    }

    // 6: Transact
    // Encoder: 06000150281c00071054657374
    function testTransact() public view {
        _assertRoundTrip(
            transact(
                TransactParams({
                    originKind: OriginKind.Native,
                    hasFallbackMaxWeight: true,
                    fallbackMaxWeight: fromParts(20, 10),
                    call: hex"00071054657374"
                })
            ),
            hex"06000150281c00071054657374"
        );
    }

    // 7: HrmpNewChannelOpenRequest
    // Encoder: 070401109101
    function testHrmpNewChannelOpenRequest() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.HrmpNewChannelOpenRequest,
                payload: hex"0401109101"
            }),
            hex"070401109101"
        );
    }

    // 8: HrmpChannelAccepted
    // Encoder: 0804
    function testHrmpChannelAccepted() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.HrmpChannelAccepted,
                payload: hex"04"
            }),
            hex"0804"
        );
    }

    // 9: HrmpChannelClosing
    // Encoder: 0904080c
    function testHrmpChannelClosing() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.HrmpChannelClosing,
                payload: hex"04080c"
            }),
            hex"0904080c"
        );
    }

    // 10: ClearOrigin
    // Encoder: 0a
    function testClearOrigin() public view {
        _assertRoundTrip(clearOrigin(), hex"0a");
    }

    // 11: DescendOrigin
    // Encoder: 0b00
    function testDescendOrigin() public view {
        _assertRoundTrip(
            descendOrigin(DescendOriginParams({interior: here()})),
            hex"0b00"
        );
    }

    // 12: ReportError
    // Encoder: 0c0000000000
    function testReportError() public view {
        QueryResponseInfo memory info = QueryResponseInfo({
            destination: Location({parents: 0, interior: here()}),
            queryId: QueryId.wrap(0),
            maxWeight: fromParts(0, 0)
        });
        _assertRoundTrip(
            reportError(ReportErrorParams({responseInfo: info})),
            hex"0c0000000000"
        );
    }

    // 13: DepositAsset
    // Encoder: 0d01000000
    function testDepositAsset() public view {
        AssetFilter memory assetFilter = wild(WildParams({wildAsset: all()}));
        _assertRoundTrip(
            depositAsset(
                DepositAssetParams({
                    assets: assetFilter,
                    beneficiary: Location({parents: 0, interior: here()})
                })
            ),
            hex"0d01000000"
        );
    }

    // 14: DepositReserveAsset
    // Encoder: 0e0100000000
    function testDepositReserveAsset() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.DepositReserveAsset,
                payload: hex"0100000000"
            }),
            hex"0e0100000000"
        );
    }

    // 15: ExchangeAsset
    // Encoder: 0f01000001
    function testExchangeAsset() public view {
        AssetFilter memory give = wild(WildParams({wildAsset: all()}));
        Assets memory want;
        _assertRoundTrip(
            exchangeAsset(
                ExchangeAssetParams({give: give, want: want, maximal: true})
            ),
            hex"0f01000001"
        );
    }

    // 16: InitiateReserveWithdraw
    // Encoder: 100100000000
    function testInitiateReserveWithdraw() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.InitiateReserveWithdraw,
                payload: hex"0100000000"
            }),
            hex"100100000000"
        );
    }

    // 17: InitiateTeleport
    // Encoder: 110100000000
    function testInitiateTeleport() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.InitiateTeleport,
                payload: hex"0100000000"
            }),
            hex"110100000000"
        );
    }

    // 18: ReportHolding
    // Encoder: 1200000000000100
    function testReportHolding() public view {
        QueryResponseInfo memory info = QueryResponseInfo({
            destination: Location({parents: 0, interior: here()}),
            queryId: QueryId.wrap(0),
            maxWeight: fromParts(0, 0)
        });
        AssetFilter memory assetFilter = wild(WildParams({wildAsset: all()}));
        _assertRoundTrip(
            reportHolding(
                ReportHoldingParams({responseInfo: info, assets: assetFilter})
            ),
            hex"1200000000000100"
        );
    }

    // 19: BuyExecution
    // Encoder: 1301000002093d0000
    function testBuyExecution() public view {
        AssetType memory fees = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1000000}))
        });
        _assertRoundTrip(
            buyExecution(
                BuyExecutionParams({fees: fees, weightLimit: unlimited()})
            ),
            hex"1301000002093d0000"
        );
    }

    // 20: RefundSurplus
    // Encoder: 14
    function testRefundSurplus() public view {
        _assertRoundTrip(refundSurplus(), hex"14");
    }

    // 21: SetErrorHandler
    // Encoder: 1500
    function testSetErrorHandler() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.SetErrorHandler,
                payload: hex"00"
            }),
            hex"1500"
        );
    }

    // 22: SetAppendix
    // Encoder: 1600
    function testSetAppendix() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.SetAppendix,
                payload: hex"00"
            }),
            hex"1600"
        );
    }

    // 23: ClearError
    // Encoder: 17
    function testClearError() public view {
        _assertRoundTrip(clearError(), hex"17");
    }

    // 24: ClaimAsset
    // Encoder: 18000000
    function testClaimAsset() public view {
        Assets memory assets;
        _assertRoundTrip(
            claimAsset(
                ClaimAssetParams({
                    assets: assets,
                    ticket: Location({parents: 0, interior: here()})
                })
            ),
            hex"18000000"
        );
    }

    // 25: Trap
    // Encoder: 1900
    function testTrap() public view {
        _assertRoundTrip(trap(TrapParams({code: 0})), hex"1900");
    }

    // 26: SubscribeVersion
    // Encoder: 1a000000
    function testSubscribeVersion() public view {
        _assertRoundTrip(
            subscribeVersion(
                SubscribeVersionParams({
                    queryId: QueryId.wrap(0),
                    maxResponseWeight: fromParts(0, 0)
                })
            ),
            hex"1a000000"
        );
    }

    // 27: UnsubscribeVersion
    // Encoder: 1b
    function testUnsubscribeVersion() public view {
        _assertRoundTrip(unsubscribeVersion(), hex"1b");
    }

    // 28: BurnAsset
    // Encoder: 1c00
    function testBurnAsset() public view {
        Assets memory assets;
        _assertRoundTrip(
            burnAsset(BurnAssetParams({assets: assets})),
            hex"1c00"
        );
    }

    // 29: ExpectAsset
    // Encoder: 1d00
    function testExpectAsset() public view {
        Assets memory assets;
        _assertRoundTrip(
            expectAsset(ExpectAssetParams({assets: assets})),
            hex"1d00"
        );
    }

    // 30: ExpectOrigin
    // Encoder: 1e010000
    function testExpectOrigin() public view {
        _assertRoundTrip(
            expectOrigin(
                ExpectOriginParams({
                    hasOrigin: true,
                    origin: Location({parents: 0, interior: here()})
                })
            ),
            hex"1e010000"
        );
    }

    // 31: ExpectError
    // Encoder: 1f00
    function testExpectError() public view {
        _assertRoundTrip(
            expectError(
                ExpectErrorParams({
                    hasError: false,
                    index: 0,
                    err: XcmError({
                        variant: XcmErrorVariant.Overflow,
                        payload: hex""
                    })
                })
            ),
            hex"1f00"
        );
    }

    // 32: ExpectTransactStatus
    // Encoder: 2000
    function testExpectTransactStatus() public view {
        MaybeErrorCode memory status = MaybeErrorCode({
            variant: MaybeErrorCodeVariant.Success,
            payload: hex""
        });
        _assertRoundTrip(
            expectTransactStatus(
                ExpectTransactStatusParams({transactStatus: status})
            ),
            hex"2000"
        );
    }

    // 33: QueryPallet
    // Encoder: 21000000000000
    function testQueryPallet() public view {
        QueryResponseInfo memory info = QueryResponseInfo({
            destination: Location({parents: 0, interior: here()}),
            queryId: QueryId.wrap(0),
            maxWeight: fromParts(0, 0)
        });
        _assertRoundTrip(
            queryPallet(
                QueryPalletParams({moduleName: hex"", responseInfo: info})
            ),
            hex"21000000000000"
        );
    }

    // 34: ExpectPallet
    // Encoder: 220000000000
    function testExpectPallet() public view {
        _assertRoundTrip(
            expectPallet(
                ExpectPalletParams({
                    index: 0,
                    name: hex"",
                    moduleName: hex"",
                    crateMajor: 0,
                    minCrateMinor: 0
                })
            ),
            hex"220000000000"
        );
    }

    // 35: ReportTransactStatus
    // Encoder: 230000000000
    function testReportTransactStatus() public view {
        QueryResponseInfo memory info = QueryResponseInfo({
            destination: Location({parents: 0, interior: here()}),
            queryId: QueryId.wrap(0),
            maxWeight: fromParts(0, 0)
        });
        _assertRoundTrip(
            reportTransactStatus(
                ReportTransactStatusParams({responseInfo: info})
            ),
            hex"230000000000"
        );
    }

    // 36: ClearTransactStatus
    // Encoder: 24
    function testClearTransactStatus() public view {
        _assertRoundTrip(clearTransactStatus(), hex"24");
    }

    // 37: UniversalOrigin
    // Encoder: 250902
    function testUniversalOrigin() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.UniversalOrigin,
                payload: hex"0902"
            }),
            hex"250902"
        );
    }

    // 38: ExportMessage
    // Encoder: 26020000
    function testExportMessage() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.ExportMessage,
                payload: hex"020000"
            }),
            hex"26020000"
        );
    }

    // 39: LockAsset
    // Encoder: 2701000002093d000000
    function testLockAsset() public view {
        AssetType memory asset = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1000000}))
        });
        _assertRoundTrip(
            lockAsset(
                LockAssetParams({
                    asset: asset,
                    unlocker: Location({parents: 0, interior: here()})
                })
            ),
            hex"2701000002093d000000"
        );
    }

    // 40: UnlockAsset
    // Encoder: 2801000002093d000000
    function testUnlockAsset() public view {
        AssetType memory asset = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1000000}))
        });
        _assertRoundTrip(
            unlockAsset(
                UnlockAssetParams({
                    asset: asset,
                    target: Location({parents: 0, interior: here()})
                })
            ),
            hex"2801000002093d000000"
        );
    }

    // 41: NoteUnlockable
    // Encoder: 2901000002093d000000
    function testNoteUnlockable() public view {
        AssetType memory asset = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1000000}))
        });
        _assertRoundTrip(
            noteUnlockable(
                NoteUnlockableParams({
                    asset: asset,
                    owner: Location({parents: 0, interior: here()})
                })
            ),
            hex"2901000002093d000000"
        );
    }

    // 42: RequestUnlock
    // Encoder: 2a01000002093d000000
    function testRequestUnlock() public view {
        AssetType memory asset = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1000000}))
        });
        _assertRoundTrip(
            requestUnlock(
                RequestUnlockParams({
                    asset: asset,
                    locker: Location({parents: 0, interior: here()})
                })
            ),
            hex"2a01000002093d000000"
        );
    }

    // 43: SetFeesMode
    // Encoder: 2b01
    function testSetFeesMode() public view {
        _assertRoundTrip(
            setFeesMode(SetFeesModeParams({jitWithdraw: true})),
            hex"2b01"
        );
    }

    // 44: SetTopic
    // Encoder: 2c0000000000000000000000000000000000000000000000000000000000000000
    function testSetTopic() public view {
        bytes32 topic;
        _assertRoundTrip(
            setTopic(SetTopicParams({topic: topic})),
            hex"2c0000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    // 45: ClearTopic
    // Encoder: 2d
    function testClearTopic() public view {
        _assertRoundTrip(clearTopic(), hex"2d");
    }

    // 46: AliasOrigin
    // Encoder: 2e0000
    function testAliasOrigin() public view {
        _assertRoundTrip(
            aliasOrigin(
                AliasOriginParams({
                    location: Location({parents: 0, interior: here()})
                })
            ),
            hex"2e0000"
        );
    }

    // 47: UnpaidExecution
    // Encoder: 2f0000
    function testUnpaidExecution() public view {
        _assertRoundTrip(
            unpaidExecution(
                UnpaidExecutionParams({
                    weightLimit: unlimited(),
                    hasCheckOrigin: false,
                    checkOrigin: Location({parents: 0, interior: here()})
                })
            ),
            hex"2f0000"
        );
    }

    // 48: PayFees
    // Encoder: 3001000002093d00
    function testPayFees() public view {
        AssetType memory asset = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1000000}))
        });
        _assertRoundTrip(
            payFees(PayFeesParams({asset: asset})),
            hex"3001000002093d00"
        );
    }

    // 49: InitiateTransfer
    // Encoder: 31000000000000
    function testInitiateTransfer() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.InitiateTransfer,
                payload: hex"000000000000"
            }),
            hex"31000000000000"
        );
    }

    // 50: ExecuteWithOrigin
    // Encoder: 320000
    function testExecuteWithOrigin() public view {
        _assertRoundTrip(
            Instruction({
                variant: InstructionVariant.ExecuteWithOrigin,
                payload: hex"0000"
            }),
            hex"320000"
        );
    }

    // 51: SetHints
    // Encoder: 3300
    function testSetHints() public view {
        Hint[] memory hints;
        _assertRoundTrip(setHints(SetHintsParams({hints: hints})), hex"3300");
    }
}
