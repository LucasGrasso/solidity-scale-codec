# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[Unreleased]

## Version 0.3.4

## Changed

- Move Definitions to website docs - []()

## Version 0.3.3

## Changed

- Homepage for the docsite - [#fcbac35](https://github.com/LucasGrasso/solidity-scale-codec/commit/757cddcce6d9f7a82f9535471c86f0cffa878956)

## Version 0.3.2

## Changed

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
