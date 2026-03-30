// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Xcm as XcmV5} from "../v5/Xcm/Xcm.sol";
import {XcmCodec as XcmV5Codec} from "../v5/Xcm/XcmCodec.sol";

/// @notice The XCM versions supported by this package.
enum XcmVersion {
    _unsupported_V2,
    _unsupported_V3,
    V5
}

/// @notice A single XCM message, together with its version code.
struct VersionedXcm {
    /// @custom:property The version of the XCM message.
    XcmVersion version;
    /// @custom:property The XCM message, encoded according to its version.
    bytes xcm;
}

/// @notice Creates a `VersionedXcm` with version `V5` from an `XcmV5` struct.
/// @param xcm The `XcmV5` struct to wrap.
/// @return A `VersionedXcm` with version `V5` and the ABI-encoded `xcm` as its payload.
function v5(XcmV5 memory xcm) pure returns (VersionedXcm memory) {
    return VersionedXcm({version: XcmVersion.V5, xcm: XcmV5Codec.encode(xcm)});
}
