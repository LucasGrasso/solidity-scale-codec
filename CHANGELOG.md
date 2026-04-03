# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[Unreleased]

## Version 1.0.0

### Added

- `BytesUtils.sol`, a new utility library for byte manipulation, including functions for copying byte arrays. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- `UnsignedUtils.sol`, a new utility library for safely converting `uint256` values to smaller unsigned integer types (`uint8`, `uint16`, `uint32`, `uint64`, `uint128`) with overflow checks. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- `XcmBuilder.sol`, a new utility library for constructing XCM messages in a more ergonomic way, with functions for building various XCM instructions. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- Added `parent()` helper function in `Location.sol` to create a `Location` struct representing the parent location (one level up in the hierarchy). - [#93618bf](https://github.com/LucasGrasso/solidity-scale-codec/commit/93618bf)
- Added `fromAsset(Asset)` and `fromAssets(Asset[])` helper functions in `Assets.sol` to construct `Assets` values ergonomically from a single asset or an array. - [#dd79e86](https://github.com/LucasGrasso/solidity-scale-codec/commit/dd79e86)

### Changed

- For every enum equivalent, rename `Type` suffix to `Variant` for better clarity and consistency. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- Type Checking with `UnsignedUtils` in all codecs to ensure safe downcasting of `uint256` to smaller unsigned integer types, preventing potential overflow issues and improving robustness. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- DRY with `BytesUtils.copy` in all codecs to replace manual byte copying loops, improving code readability, maintainability, and gas efficiency. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- Removed unnecessary length checks at the beginning of decoding functions since `encodedSizeAt` and `BytesUtils.copy` will handle those checks and revert if data is insufficient, simplifying the code and centralizing error handling. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- Moved helper `Junction` functions to outside of the codec. - [#b91bdfa](https://github.com/LucasGrasso/solidity-scale-codec/commit/b91bdfa24472fe931ee5dd6625ae2b4796d23248)

### Fixed

- Inconsistencies in Xcm Codec libraries:
  - `decode`, `decodeAt` functions not returning `bytesRead` in some codecs. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
  - Now returning `{Variant}Params` structs in `as{Variant}` decoding functions for consistency and better ergonomics. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- Inconsistencies in Xcm Instruction factory functions:
  - Some factory functions were taking individual parameters instead of `{Variant}Params` structs, leading to less consistent and ergonomic API. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- Now checking Variant bounds when calling `decodeAt` at all enum equivalents. - [#3](https://github.com/LucasGrasso/solidity-scale-codec/pull/3)
- Optional encoding in `Junction` factory functions was not correctly implemented, leading to incorrect encoding when `hasNetwork` was false. - [#93618bf](https://github.com/LucasGrasso/solidity-scale-codec/commit/93618bf)

## Version 0.3.4

### Changed

- Move Definitions to website docs - [#f57c914](https://github.com/LucasGrasso/solidity-scale-codec/commit/7e88534930cdb8ac47b5f16a02f2203c588a7e7f)

## Version 0.3.3

### Changed

- Homepage for the docsite - [#fcbac35](https://github.com/LucasGrasso/solidity-scale-codec/commit/757cddcce6d9f7a82f9535471c86f0cffa878956)

## Version 0.3.2

### Changed

- Better Changelog - [#288b3e9](https://github.com/LucasGrasso/solidity-scale-codec/commit/288b3e966ff1d030b7e50dcc40d0610cd30b201c)

## Version 0.3.1

### Fixed

- Fix Doc Site - [#da72e55](https://github.com/LucasGrasso/solidity-scale-codec/commit/dc4c9becb5495187078dee73932a89ffa5c7febf)

## Version 0.3

### Added

- Documentation Site - [#eec06ff](https://github.com/LucasGrasso/solidity-scale-codec/commit/ec06ff0faa1405914893966e91bfe99d1196986)

### Fixed

- Fix docs in Junctions - [#de668af](https://github.com/LucasGrasso/solidity-scale-codec/commit/e7b8edbfd6f965c0120cb2572f24e3c8e81c78fe)

## Version 0.2.0

### Added

- Implemented complete XCM v5 support surface with full Instruction model (all variants with Params and factory functions), Instruction/Xcm/VersionedXcm codecs, XCM helper utilities, VersionedXcm harness and cross-fuzz script scaffolding, plus README XCM usage documentation. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

- Added Codecs for Bytes, Address - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

### Changed

- Hardened decoding safety and consistency by fixing Transact call length handling, adding/trimming bounds checks at codec boundaries (Response, XcmError, VersionedXcm, Compact, and generated array codecs), updating array codegen template to preserve those checks, and standardizing docs/comments/style across the XCM v5 folder. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

- Fix typos and add `encodedSizeAt` functions to all codecs for better safety and consistency. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

- General code cleanup and refactoring. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)
