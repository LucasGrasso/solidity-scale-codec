// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {XcmError, XcmErrorVariant, unit, trap, UnitParams, TrapParams} from "../../../src/Xcm/v5/XcmError/XcmError.sol";
import {XcmErrorCodec as Codec} from "../../../src/Xcm/v5/XcmError/XcmErrorCodec.sol";
import {Test} from "forge-std/Test.sol";

contract XcmErrorWrapper {
    function decode(bytes memory data) external pure returns (XcmError memory) {
        (XcmError memory result, ) = Codec.decode(data);
        return result;
    }
}

contract XcmErrorTest is Test {
    XcmErrorWrapper private wrapper;

    function setUp() public {
        wrapper = new XcmErrorWrapper();
    }

    function _assertRoundTrip(
        XcmError memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        XcmError memory decoded = wrapper.decode(expected);
        assertEq(uint8(decoded.variant), uint8(value.variant));
        assertEq(decoded.payload, value.payload);
    }

    // Test unit error variants
    function testEncodeDecodeOverflow() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.Overflow})),
            hex"00"
        );
    }

    function testEncodeDecodeUnimplemented() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.Unimplemented})),
            hex"01"
        );
    }

    function testEncodeDecodeUntrustedReserveLocation() public view {
        _assertRoundTrip(
            unit(
                UnitParams({variant: XcmErrorVariant.UntrustedReserveLocation})
            ),
            hex"02"
        );
    }

    function testEncodeDecodeUntrustedTeleportLocation() public view {
        _assertRoundTrip(
            unit(
                UnitParams({variant: XcmErrorVariant.UntrustedTeleportLocation})
            ),
            hex"03"
        );
    }

    function testEncodeDecodeLocationFull() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.LocationFull})),
            hex"04"
        );
    }

    function testEncodeDecodeLocationNotInvertible() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.LocationNotInvertible})),
            hex"05"
        );
    }

    function testEncodeDecodeBadOrigin() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.BadOrigin})),
            hex"06"
        );
    }

    function testEncodeDecodeInvalidLocation() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.InvalidLocation})),
            hex"07"
        );
    }

    function testEncodeDecodeAssetNotFound() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.AssetNotFound})),
            hex"08"
        );
    }

    function testEncodeDecodeFailedToTransactAsset() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.FailedToTransactAsset})),
            hex"09"
        );
    }

    function testEncodeDecodeNotWithdrawable() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.NotWithdrawable})),
            hex"0a"
        );
    }

    function testEncodeDecodeLocationCannotHold() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.LocationCannotHold})),
            hex"0b"
        );
    }

    function testEncodeDecodeExceedsMaxMessageSize() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.ExceedsMaxMessageSize})),
            hex"0c"
        );
    }

    function testEncodeDecodeDestinationUnsupported() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.DestinationUnsupported})),
            hex"0d"
        );
    }

    function testEncodeDecodeTransport() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.Transport})),
            hex"0e"
        );
    }

    function testEncodeDecodeUnroutable() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.Unroutable})),
            hex"0f"
        );
    }

    function testEncodeDecodeUnknownClaim() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.UnknownClaim})),
            hex"10"
        );
    }

    function testEncodeDecodeFailedToDecode() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.FailedToDecode})),
            hex"11"
        );
    }

    function testEncodeDecodeMaxWeightInvalid() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.MaxWeightInvalid})),
            hex"12"
        );
    }

    function testEncodeDecodeNotHoldingFees() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.NotHoldingFees})),
            hex"13"
        );
    }

    function testEncodeDecodeTooExpensive() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.TooExpensive})),
            hex"14"
        );
    }

    function testEncodeDecodeExpectationFalse() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.ExpectationFalse})),
            hex"16"
        );
    }

    function testEncodeDecodePalletNotFound() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.PalletNotFound})),
            hex"17"
        );
    }

    function testEncodeDecodeNameMismatch() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.NameMismatch})),
            hex"18"
        );
    }

    function testEncodeDecodeVersionIncompatible() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.VersionIncompatible})),
            hex"19"
        );
    }

    function testEncodeDecodeHoldingWouldOverflow() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.HoldingWouldOverflow})),
            hex"1a"
        );
    }

    function testEncodeDecodeExportError() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.ExportError})),
            hex"1b"
        );
    }

    function testEncodeDecodeReanchorFailed() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.ReanchorFailed})),
            hex"1c"
        );
    }

    function testEncodeDecodeNoDeal() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.NoDeal})),
            hex"1d"
        );
    }

    function testEncodeDecodeFeesNotMet() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.FeesNotMet})),
            hex"1e"
        );
    }

    function testEncodeDecodeLockError() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.LockError})),
            hex"1f"
        );
    }

    function testEncodeDecodeNoPermission() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.NoPermission})),
            hex"20"
        );
    }

    function testEncodeDecodeUnanchored() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.Unanchored})),
            hex"21"
        );
    }

    function testEncodeDecodeNotDepositable() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.NotDepositable})),
            hex"22"
        );
    }

    function testEncodeDecodeTooManyAssets() public view {
        _assertRoundTrip(
            unit(UnitParams({variant: XcmErrorVariant.TooManyAssets})),
            hex"23"
        );
    }

    function testEncodeDecodeTrapWithCode() public view {
        _assertRoundTrip(trap(TrapParams({code: 9})), hex"150900000000000000");
    }

    function testEncodeDecodeTrapWithLargeCode() public view {
        _assertRoundTrip(
            trap(TrapParams({code: 0x0807060504030201})),
            hex"150102030405060708"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"24");
    }

    function testDecodeRevertsOnTruncatedTrapPayload() public {
        vm.expectRevert();
        wrapper.decode(hex"15");
    }

    function testDecodeRevertsOnTruncatedTrapPayload2() public {
        vm.expectRevert();
        wrapper.decode(hex"150102030405");
    }
}
