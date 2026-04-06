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

### **Scale**

High-level SCALE codec for various data types:

- **Address** — Ethereum Address encoding
- **Arrays** — Bool, Int, and Uint arrays
- **Bytes** — Fixed-size and Variable-syze byte arrays
- **Compact** — Compact integer Encoding or Scale length encoding.
- **Signed** — Two's complement signed integers
- **Unsigned** — Standard unsigned integers

### **Xcm**

Cross-consensus message format support:

- **v5** — XCM protocol version 5 with full instruction codec.

## Getting Started

See the sidebar for detailed API documentation of all contracts and types.

Use the search feature to quickly find specific functions or types.

## License

Apache-2.0
