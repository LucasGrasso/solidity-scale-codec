# SCALE Encoding Test Oracle

This directory contains the Rust encoder that generates all test data for the Solidity SCALE codec tests.

## Overview

The Rust encoder is the **source of truth** for all XCM v5 encodings. It uses the Polkadot SDK reference implementation to ensure test data is 100% correct.

## Building

```bash
cd rust-encoder
cargo build --release
```

## Generating Test Data

```bash
cd rust-encoder
cargo run --release > output.txt
```

This generates variants for each subtype of Xcm (v5).

## Output Format

Example:

```
instruction_withdraw_asset 0000
instruction_transact 06000150281c00071054657374
instruction_expect_origin 1e010000
```

## Using Generated Data in Tests

All test data in `test/Xcm/v5/*.t.sol` matches the output of this encoder. The expected hex values in test assertions come directly from running:

```bash
cargo run --release > output.txt
```

If XCM encoding changes, regenerate this file and update corresponding test files.

## Verification

To verify a specific type encoding:

1. Run the encoder: `cargo run --release > output.txt`
2. Find the line in `output.txt` for your type
3. Use that hex value in the Solidity test

Example:

```solidity
function testTransact() public view {
    _assertRoundTrip(
        transact(TransactParams({...})),
        hex"06000150281c00071054657374"  // From output.txt
    );
}
```
