# Solidity Scale Codec

## Description

[Substrate](https://github.com/paritytech/substrate) uses a lightweight and efficient [encoding and decoding program](https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding/#data-encoding) to optimize how data is sent and received over the network. The program used to serialize and deserialize data is called the SCALE codec, with SCALE being an acronym for **S**imple **C**oncatenated **A**ggregate **L**ittle-**E**ndian.

## Examples of different types

| Type      | Description                                                                                                                                                                                                                                             | Example | Encoding   |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| `bool`    | Boolean values are encoded using the least significant bit of a single byte.                                                                                                                                                                            | `true`  | `0x01`     |
| `uintN`   | Unsigned integers are encoded using a fixed-width little-endian (LE) format.                                                                                                                                                                            | `42`    | `0x2a00`   |
| `intN`    | Signed integers are encoded using a fixed-width twos-complement little-endian (LE) format.                                                                                                                                                              | `-1`    | `0xff`     |
| `Compact` | A "compact" or general integer encoding is sufficient for encoding large integers (up to 2\*\*536) and is more efficient at encoding most values than the fixed-width version. (Though for single-byte values, the fixed-width integer is never worse.) | `0`     | `0x00`     |
| `Vectors` | A collection of same-typed values is encoded, prefixed with a compact encoding of the number of items, followed by each item's encoding concatenated in turn. Currently `[uintN]`,`[intN]`, `[bool]` are supported.                                     | `[1,0]` | `0x080100` |

This repo provides an implementation of the SCALE codec in solidity.

## Usage

### Running Tests

To run all the tests in the project, execute the following command:

```shell
npx hardhat test
```

You can also selectively run the Solidity or `node:test` tests:

```shell
npx hardhat test solidity
npx hardhat test nodejs
```

## License

Copyright 2025 Lucas Grasso

This project is licensed under the the [Apache License, Version 2.0](LICENSE).
