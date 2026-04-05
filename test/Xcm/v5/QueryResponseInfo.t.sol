// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {QueryResponseInfo} from "../../../src/Xcm/v5/QueryResponseInfo/QueryResponseInfo.sol";
import {QueryResponseInfoCodec as Codec} from "../../../src/Xcm/v5/QueryResponseInfo/QueryResponseInfoCodec.sol";
import {Location, parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {Junctions, here} from "../../../src/Xcm/v5/Junctions/Junctions.sol";
import {Weight} from "../../../src/Xcm/v5/Weight/Weight.sol";
import {QueryId} from "../../../src/Xcm/v5/Types/QueryId.sol";
import {Test} from "forge-std/Test.sol";

contract QueryResponseInfoWrapper {
    function decode(bytes memory data) external pure returns (QueryResponseInfo memory) {
        (QueryResponseInfo memory result, ) = Codec.decode(data);
        return result;
    }
}

contract QueryResponseInfoTest is Test {
    QueryResponseInfoWrapper private wrapper;

    function setUp() public {
        wrapper = new QueryResponseInfoWrapper();
    }

    function _assertRoundTrip(QueryResponseInfo memory value, bytes memory expected) internal view {
        assertEq(Codec.encode(value), expected);
        QueryResponseInfo memory decoded = wrapper.decode(expected);
        assertEq(QueryId.unwrap(decoded.queryId), QueryId.unwrap(value.queryId));
        assertEq(decoded.maxWeight.refTime, value.maxWeight.refTime);
        assertEq(decoded.maxWeight.proofSize, value.maxWeight.proofSize);
    }

    // Test with parent location, query_id=7, weight=from_parts(5, 11)
    // Encoder: 01001c142c
    function testEncodeDecodeParentLocation() public view {
        QueryResponseInfo memory info = QueryResponseInfo({
            destination: parent(),
            queryId: QueryId.wrap(7),
            maxWeight: Weight({refTime: 5, proofSize: 11})
        });
        _assertRoundTrip(
            info,
            hex"01001c142c"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnTruncatedQueryId() public {
        vm.expectRevert();
        wrapper.decode(hex"0001020304");
    }

    function testDecodeRevertsOnTruncatedWeight() public {
        vm.expectRevert();
        wrapper.decode(hex"002a000000000000");
    }
}
