// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LocationCodec, Location} from "./Location.sol";
import {WeightCodec, Weight} from "./Weight.sol";
import {QueryId} from "./Types/QueryId.sol";
import {Compact} from "../../Scale/Compact.sol";

/// @notice Information regarding the composition of a query response.
struct QueryResponseInfo {
    /// @custom:property The destination to which the query response message should be sent.
    Location destination;
    /// @custom:property The `query_id` field of the `QueryResponse` message.
    QueryId queryId;
    /// @custom:property The `max_weight` field of the `QueryResponse` message.
    Weight maxWeight;
}

/// @title SCALE Codec for XCM v5 `QueryResponseInfo`
/// @notice SCALE-compliant encoder/decoder for the `QueryResponseInfo` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library QueryResponseInfoCodec {
    error InvalidQueryResponseInfoLength();

    /// @notice Encodes a `QueryResponseInfo` struct into SCALE bytes.
    /// @param info The `QueryResponseInfo` struct to encode.
    /// @return SCALE-encoded bytes representing the `QueryResponseInfo`.
    function encode(
        QueryResponseInfo memory info
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                LocationCodec.encode(info.destination),
                Compact.encode(QueryId.unwrap(info.queryId)),
                WeightCodec.encode(info.maxWeight)
            );
    }

    /// @notice Returns the number of bytes that a `QueryResponseInfo` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `QueryResponseInfo`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `QueryResponseInfo`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidQueryResponseInfoLength();
        uint256 pos = offset;
        pos += LocationCodec.encodedSizeAt(data, pos);
        pos += Compact.encodedSizeAt(data, pos);
        pos += WeightCodec.encodedSizeAt(data, pos);
        return pos - offset;
    }

    /// @notice Decodes a `QueryResponseInfo` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `QueryResponseInfo`.
    /// @return info The decoded `QueryResponseInfo` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (QueryResponseInfo memory info, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `QueryResponseInfo` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `QueryResponseInfo`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return info The decoded `QueryResponseInfo` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (QueryResponseInfo memory info, uint256 bytesRead) {
        if (data.length < offset + 1) revert InvalidQueryResponseInfoLength();
        uint256 pos = offset;
        uint256 read;

        Location memory destination;
        (destination, read) = LocationCodec.decodeAt(data, pos);
        pos += read;

        uint256 queryId;
        (queryId, read) = Compact.decodeAt(data, pos);
        pos += read;

        Weight memory maxWeight;
        (maxWeight, read) = WeightCodec.decodeAt(data, pos);
        pos += read;

        info = QueryResponseInfo({
            destination: destination,
            queryId: QueryId.wrap(uint64(queryId)),
            maxWeight: maxWeight
        });
        bytesRead = pos - offset;
    }
}
