## Version

### Added

Implemented complete XCM v5 support surface with full Instruction model (all variants with Params and factory functions), Instruction/Xcm/VersionedXcm codecs, XCM helper utilities, VersionedXcm harness and cross-fuzz script scaffolding, plus README XCM usage documentation.

### Changed

Hardened decoding safety and consistency by fixing Transact call length handling, adding/trimming bounds checks at codec boundaries (Response, XcmError, VersionedXcm, Compact, and generated array codecs), updating array codegen template to preserve those checks, and standardizing docs/comments/style across the XCM v5 folder.
