// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {VersionedXcm, XcmVersion} from "./VersionedXcm.sol";
import {Xcm as XcmV5} from "../v5/Xcm/Xcm.sol";
import {XcmCodec as XcmV5Codec} from "../v5/Xcm/XcmCodec.sol";

library VersionedXcmCodec {
    error InvalidVersionedXcmLength();
    error UnsupportedXcmVersion(XcmVersion version);

    /// @notice Encodes a `VersionedXcm` into bytes, using the appropriate encoding for its version.
    /// @param versionedXcm The `VersionedXcm` to encode.
    /// @return The encoded bytes of the `VersionedXcm`.
    function encode(
        VersionedXcm memory versionedXcm
    ) internal pure returns (bytes memory) {
        if (versionedXcm.version == XcmVersion.V5) {
            return
                abi.encodePacked(uint8(versionedXcm.version), versionedXcm.xcm);
        } else {
            revert UnsupportedXcmVersion(versionedXcm.version);
        }
    }

    /// @notice Decodes a `VersionedXcm` from bytes, using the appropriate decoding for its version.
    /// @param data The byte sequence containing the encoded `VersionedXcm`.
    /// @return versionedXcm The decoded `VersionedXcm` struct.
    /// @return bytesRead The number of bytes read from `data` to decode the `VersionedXcm`.
    function decode(
        bytes memory data
    )
        internal
        pure
        returns (VersionedXcm memory versionedXcm, uint256 bytesRead)
    {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `VersionedXcm` from bytes starting at a given offset, using the appropriate decoding for its version.
    /// @param data The byte sequence containing the encoded `VersionedXcm`.
    /// @param offset The starting index in `data` from which to decode the `VersionedXcm`.
    /// @return versionedXcm The decoded `VersionedXcm` struct.
    /// @return bytesRead The number of bytes read from `data` to decode the `VersionedXcm`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    )
        internal
        pure
        returns (VersionedXcm memory versionedXcm, uint256 bytesRead)
    {
        XcmVersion version = XcmVersion(uint8(data[offset]));
        uint256 xcmByteLength;
        bytes memory xcmBytes;
        if (version == XcmVersion.V5) {
            xcmByteLength = XcmV5Codec.encodedSizeAt(data, offset + 1);
            if (data.length < offset + 1 + xcmByteLength)
                revert InvalidVersionedXcmLength();
            xcmBytes = new bytes(xcmByteLength);
            for (uint256 i = 0; i < xcmByteLength; i++)
                xcmBytes[i] = data[offset + 1 + i];
            versionedXcm = VersionedXcm({version: version, xcm: xcmBytes});
            bytesRead = 1 + xcmByteLength;
        } else {
            revert UnsupportedXcmVersion(version);
        }
    }
}
