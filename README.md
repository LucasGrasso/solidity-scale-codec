# Solidity Scale Codec

## Description

[Substrate](https://github.com/paritytech/substrate) uses a lightweight and efficient [encoding and decoding program](https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding/#data-encoding) to optimize how data is sent and received over the network. The program used to serialize and deserialize data is called the SCALE codec, with SCALE being an acronym for **S**imple **C**oncatenated **A**ggregate **L**ittle-**E**ndian.

## Examples of different types

| Type    | Description                                                                                | Example | Encoding |
| ------- | ------------------------------------------------------------------------------------------ | ------- | -------- |
| `bool`  | Boolean values are encoded using the least significant bit of a single byte.               | `true`  | `0x01`   |
| `uintN` | Unsigned integers are encoded using a fixed-width little-endian (LE) format.               | `42`    | `0x2a00` |
| `intN`  | Signed integers are encoded using a fixed-width twos-complement little-endian (LE) format. | `-1`    | `0xff`   |

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
