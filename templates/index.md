---
hero:
  name: "{{siteTitle}}"
  text: "Smart Contract Documentation"
  tagline: { { description } }
  actions:
    - theme: brand
      text: "View API Docs"
      link: /
    - theme: alt
      text: "GitHub"
      link: "{{repository}}"
---

# Solidity Scale Codec

[![GitHub License](https://img.shields.io/github/license/LucasGrasso/solidity-scale-codec)](https://github.com/LucasGrasso/solidity-scale-codec/blob/main/LICENSE)

```bash
# Install with npm
npm install solidity-scale-codec

# Or with yarn
yarn add solidity-scale-codec

# Or with pnpm
pnpm add solidity-scale-codec
```

## Overview

{{siteTitle}} provides a Solidity implementation of the [SCALE codec](https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding/#data-encoding), the encoding protocol used by Substrate to optimize data serialization over the network.

Check the [Formal definitions](https://lucasgrasso.github.io/solidity-scale-codec/guides/Definitions.html) if you have further doubts.

## Library Categories

### **LittleEndian**

Low-level byte encoding for unsigned integers:

- U8, U16, U32, U64, U128, U256

```solidity
import "solidity-scale-codec/src/LittleEndian/U8.sol";
//...
import "solidity-scale-codec/src/LittleEndian/U256.sol";
```

### **Scale**

High-level SCALE codec for various data types:

- **Address** — Ethereum Address encoding
- **Arrays** — Bool, Int, and Uint arrays
- **Bytes** — Fixed-size and Variable-size byte arrays
- **Compact** — Compact integer Encoding or Scale length encoding.
- **Signed** — Two's complement signed integers
- **Unsigned** — Standard unsigned integers

```solidity
// Unsigned integers
import "solidity-scale-codec/src/Scale/Unsigned.sol";
// Signed integers
import "solidity-scale-codec/src/Scale/Signed.sol";
// Booleans
import "solidity-scale-codec/src/Scale/Bool.sol";
/// Fixed-size and variable-size byte arrays
import "solidity-scale-codec/src/Scale/Bytes.sol";
/// Compact integer encoding
import "solidity-scale-codec/src/Scale/Compact.sol";
/// Ethereum address encoding
import "solidity-scale-codec/src/Scale/Address.sol";
/// Arrays
import "solidity-scale-codec/src/Scale/Arrays.sol";
```

### **Xcm**

Cross-consensus message format support:

#### **v5**

You may find all type definitions and factory functions for those types at

```solidity
import "solidity-scale-codec/src/Xcm/v5/v5.sol";
```

(or more specific paths for specific types, for example)

```solidity
import "solidity-scale-codec/src/Xcm/v5/Location/Location.sol";
```

Type-specific Codecs are found at their respective paths, for example:

```solidity
import { WeightCodec } from "solidity-scale-codec/src/Xcm/v5/Weight/WeightCodec.sol";
```

## Getting Started

See the sidebar for detailed API documentation of all contracts and types.

Use the search feature to quickly find specific functions or types.

## License

Apache-2.0
