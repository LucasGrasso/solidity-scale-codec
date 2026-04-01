# Solidity Scale Codec

<a href="https://www.npmjs.com/package/solidity-scale-codec" target="_blank"><img alt="NPM Version" src="https://img.shields.io/npm/v/solidity-scale-codec">
</a>
<a href="https://github.com/LucasGrasso/solidity-scale-codec/blob/main/LICENSE" target="_blank"><img alt="GitHub License" src="https://img.shields.io/github/license/LucasGrasso/solidity-scale-codec"></a>

📖 **[View Documentation](https://lucasgrasso.github.io/solidity-scale-codec/)** — Documentation site with API reference

## Description

[Substrate](https://github.com/paritytech/substrate) uses a lightweight and efficient [encoding and decoding program](https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding/#data-encoding) to optimize how data is sent and received over the network. The program used to serialize and deserialize data is called the SCALE codec, with SCALE being an acronym for **S**imple **C**oncatenated **A**ggregate **L**ittle-**E**ndian.

This library provides a Highly-Modular implementation of SCALE in solidity.

## Examples of different types

| Type      | Description                                                                                                                                                                                                                                             | Example | Encoding   |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ---------- |
| `bool`    | Boolean values are encoded using the least significant bit of a single byte.                                                                                                                                                                            | `true`  | `0x01`     |
| `uintN`   | Unsigned integers are encoded using a fixed-width little-endian (LE) format.                                                                                                                                                                            | `42`    | `0x2a00`   |
| `intN`    | Signed integers are encoded using a fixed-width twos-complement little-endian (LE) format.                                                                                                                                                              | `-1`    | `0xff`     |
| `Compact` | A "compact" or general integer encoding is sufficient for encoding large integers (up to 2\*\*536) and is more efficient at encoding most values than the fixed-width version. (Though for single-byte values, the fixed-width integer is never worse.) | `0`     | `0x00`     |
| `Arrays`  | A collection of same-typed values is encoded, prefixed with a compact encoding of the number of items, followed by each item's encoding concatenated in turn. Currently `[uintN]`,`[intN]`, `[bool]` are supported.                                     | `[1,0]` | `0x080100` |

See the [Definitions](https://lucasgrasso.github.io/solidity-scale-codec/Definitions.html) for more details on the encoding of different types.

## Usage

## Encode Structs

See this [example](https://github.com/LucasGrasso/solidity-scale-codec/blob/main/contracts/examples/Foo.sol).

## About the libraries

### src/LittleEndian

The `LittleEndian` library provides functions to encode and decode unsigned integers in little-endian format.

All libraries here provide the following functions:

```solidity
function toLittleEndian(uintN value) internal pure returns (bytesM){}
function fromLittleEndian(
	bytes memory data,
	uint256 offset
) internal pure returns (uintN value) {}
```

### src/Scale

The `Scale` library provides functions to encode and decode various types in the SCALE format, including booleans, unsigned integers, signed integers, compact integers, and arrays of these types.

- All Codec libraries provide the following encoding functions:

  ```solidity
  function encode(T value) internal pure returns (bytes memory){}
  function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256 size){}
  ```

- Libraries for fixed length types provide the following functions for encoding:

  ```solidity
  function decode(bytes memory data) internal pure returns (T value){}
  function decodeAt(bytes memory data, uint256 offset) internal pure returns (T value){}
  ```

  > Note: `decode(data)` = `decodeAt(data, 0)`

  Integer libraries also provide Little-Endian encoding functions, using the `LittleEndian` library:

  ```solidity
  function toLittleEndian(T value) internal pure returns (bytesM){}
  ```

- Variable length types libraries provide the same encoding functions, but the decoding functions also return the number of bytes read from the input data. This is useful for decoding from a larger byte array where the encoded value is not at the beginning.

  ```solidity
  function decode(bytes memory data) internal pure returns (T value, uint256 bytesRead){}
  function decodeAt(bytes memory data, uint256 offset) internal pure returns (T value, uint256 bytesRead){}
  ```

  > Note: `decode(data)` = `decodeAt(data, 0)`

### src/Xcm

The `Xcm` library contains SCALE-compatible Solidity representations and codecs for XCM types.

Current support includes:

- XCM v5 domain types in `src/Xcm/v5/*` (instructions, locations, assets, responses, errors, weights, and related codecs).
- A versioned wrapper in `src/Xcm/VersionedXcm/*`.

Implementation notes:

- Enum-like XCM types are represented as structs with a type discriminator plus `bytes payload`.
- Each type has a codec library with `encode`, `encodedSizeAt`, `decode`, and `decodeAt`.
- `VersionedXcm` currently supports v5 payloads.

Minimal usage example:

```solidity
import {Instruction} from "../src/Xcm/v5/Instruction/Instruction.sol";
import {Xcm, fromInstructions} from "../src/Xcm/v5/Xcm/Xcm.sol";
import {v5} from "../src/Xcm/VersionedXcm/VersionedXcm.sol";
import {VersionedXcmCodec} from "../src/Xcm/VersionedXcm/VersionedXcmCodec.sol";
import {Weight} from "../src/Xcm/v5/Weight/Weight.sol";
import {WeightCodec} from "../src/Xcm/v5/Weight/WeightCodec.sol";

address constant XCM_PRECOMPILE_ADDRESS = 0x00000000000000000000000000000000000a0000;

contract XcmWeightEstimator {
  function weighMessage(
    Instruction[] memory instructions
  ) external view returns (Weight memory) {
    Xcm memory xcm = fromInstructions(instructions);
    (bool success, bytes memory result) = XCM_PRECOMPILE_ADDRESS.staticcall(
      VersionedXcmCodec.encode(v5(xcm))
    );
    require(success, "XCM precompile call failed");
    (Weight memory weight, ) = WeightCodec.decode(result);
    return weight;
  }
}

```

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
