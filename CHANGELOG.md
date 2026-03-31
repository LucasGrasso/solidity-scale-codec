## Version 0.2.1

### Added

- Documentation Site - [#eec06ff...1196986](https://github.com/LucasGrasso/solidity-scale-codec/commit/ec06ff0faa1405914893966e91bfe99d1196986)

### Changed

- Fix docs in Junctions - [#de668af..e7b8edb](https://github.com/LucasGrasso/solidity-scale-codec/commit/e7b8edbfd6f965c0120cb2572f24e3c8e81c78fe)

## Version 0.2.0

### Added

- Implemented complete XCM v5 support surface with full Instruction model (all variants with Params and factory functions), Instruction/Xcm/VersionedXcm codecs, XCM helper utilities, VersionedXcm harness and cross-fuzz script scaffolding, plus README XCM usage documentation. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

- Added Codecs for Bytes, Address - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

### Changed

- Hardened decoding safety and consistency by fixing Transact call length handling, adding/trimming bounds checks at codec boundaries (Response, XcmError, VersionedXcm, Compact, and generated array codecs), updating array codegen template to preserve those checks, and standardizing docs/comments/style across the XCM v5 folder. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

- Fix typos and add `encodedSizeAt` functions to all codecs for better safety and consistency. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)

- General code cleanup and refactoring. - [#2](https://github.com/LucasGrasso/solidity-scale-codec/pull/2)
