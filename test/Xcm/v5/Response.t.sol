// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {
    Response,
    ResponseVariant,
    null_,
    assets,
    executionResult,
    version,
    palletsInfo,
    dispatchResult,
    AssetsParams,
    ExecutionResultParams,
    VersionParams,
    PalletsInfoParams,
    DispatchResultParams
} from "../../../src/Xcm/v5/Response/Response.sol";
import {ResponseCodec as Codec} from "../../../src/Xcm/v5/Response/ResponseCodec.sol";
import {Assets} from "../../../src/Xcm/v5/Assets/Assets.sol";
import {Asset} from "../../../src/Xcm/v5/Asset/Asset.sol";
import {AssetId} from "../../../src/Xcm/v5/AssetId/AssetId.sol";
import {
    Fungibility,
    fungible,
    FungibleParams
} from "../../../src/Xcm/v5/Fungibility/Fungibility.sol";
import {Location, parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {
    XcmError,
    XcmErrorVariant,
    unit,
    trap,
    UnitParams,
    TrapErrorParams
} from "../../../src/Xcm/v5/XcmError/XcmError.sol";
import {PalletInfo} from "../../../src/Xcm/v5/PalletInfo/PalletInfo.sol";
import {
    MaybeErrorCode,
    success,
    error,
    ErrorParams
} from "../../../src/Xcm/v3/MaybeErrorCode/MaybeErrorCode.sol";
import {Test} from "forge-std/Test.sol";

contract ResponseWrapper {
    function decode(bytes memory data) external pure returns (Response memory) {
        (Response memory result, ) = Codec.decode(data);
        return result;
    }
}

contract ResponseTest is Test {
    ResponseWrapper private wrapper;

    function setUp() public {
        wrapper = new ResponseWrapper();
    }

    function _assertRoundTrip(
        Response memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        Response memory decoded = wrapper.decode(expected);
        assertEq(uint8(decoded.variant), uint8(value.variant));
        assertEq(decoded.payload, value.payload);
    }

    // Test Null variant (hex: 00)
    function testEncodeDecodeNull() public view {
        _assertRoundTrip(null_(), hex"00");
    }

    // Test Assets variant with one fungible asset
    // Encoder: response_assets: 010401000003008c8647
    function testEncodeDecodeAssets() public view {
        Asset[] memory assetArray = new Asset[](1);
        assetArray[0] = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1200000000}))
        });

        Assets memory assetsStruct;
        assetsStruct.items = assetArray;

        _assertRoundTrip(
            assets(AssetsParams({assets: assetsStruct})),
            hex"010401000003008c8647"
        );
    }

    // Test ExecutionResult variant with no error (hex: 0200)
    function testEncodeDecodeExecutionResultNoError() public view {
        _assertRoundTrip(
            executionResult(
                ExecutionResultParams({
                    hasError: false,
                    index: 0,
                    err: unit(UnitParams({variant: XcmErrorVariant.Overflow}))
                })
            ),
            hex"0200"
        );
    }

    // Test ExecutionResult variant with error
    // Encoder: response_execution_result_some: 020103000000150700000000000000
    function testEncodeDecodeExecutionResultWithError() public view {
        _assertRoundTrip(
            executionResult(
                ExecutionResultParams({
                    hasError: true,
                    index: 3,
                    err: trap(TrapErrorParams({code: 7}))
                })
            ),
            hex"020103000000150700000000000000"
        );
    }

    // Test Version variant (hex: 0305000000)
    function testEncodeDecodeVersion() public view {
        _assertRoundTrip(version(VersionParams({version: 5})), hex"0305000000");
    }

    // Test PalletsInfo variant
    // Encoder: response_pallets_info: 0404282062616c616e6365733c70616c6c65745f62616c616e63657304080c
    function testEncodeDecodePalletsInfo() public view {
        PalletInfo[] memory pallets = new PalletInfo[](1);
        pallets[0] = PalletInfo({
            index: 10,
            name: "balances",
            moduleName: "pallet_balances",
            major: 1,
            minor: 2,
            patch: 3
        });

        _assertRoundTrip(
            palletsInfo(PalletsInfoParams({pallets: pallets})),
            hex"0404282062616c616e6365733c70616c6c65745f62616c616e63657304080c"
        );
    }

    // Test DispatchResult variant with success (hex: 0500)
    function testEncodeDecodeDispatchResultSuccess() public view {
        _assertRoundTrip(
            dispatchResult(DispatchResultParams({result: success()})),
            hex"0500"
        );
    }

    // Test DispatchResult variant with error
    // Encoder: response_dispatch_result_error: 05010c010203
    function testEncodeDecodeDispatchResultError() public view {
        _assertRoundTrip(
            dispatchResult(
                DispatchResultParams({
                    result: error(ErrorParams({errorBytes: hex"010203"}))
                })
            ),
            hex"05010c010203"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"07");
    }

    function testDecodeRevertsOnTruncatedVersion() public {
        vm.expectRevert();
        wrapper.decode(hex"0301");
    }

    function testDecodeRevertsOnTruncatedExecutionResult() public {
        vm.expectRevert();
        wrapper.decode(hex"0201050000");
    }
}
