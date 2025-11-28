import { readFileSync, writeFileSync } from "fs";
import path, { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const config = JSON.parse(
  readFileSync(path.join(__dirname, "config.json"), "utf-8")
);
const template = readFileSync(
  path.join(__dirname, "Array.sol.template"),
  "utf-8"
);

let output = `
// SPDX-License-Identifier: Apache-2.0
// AUTO-GENERATED - DO NOT EDIT
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import {ScaleCodec} from "./ScaleCodec.sol";

/// @title Scale Codec for solidity arrays.
/// @notice SCALE-compliant encoder/decoder for solidity arrays.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library ScaleCodecArrays {
`;

for (const { type, Type, size } of config.arrays) {
  output += template
    .replaceAll("{{type}}", type)
    .replaceAll("{{Type}}", Type)
    .replaceAll("{{size}}", size.toString());
  output += "\n";
}

output += "}\n";

writeFileSync("contracts/libraries/ScaleCodec/ScaleCodecArrays.sol", output);
console.log("Generated ScaleCodecArrays.sol");
