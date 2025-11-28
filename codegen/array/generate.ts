import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
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

const output_dir = "src/Scale/Array/";
if (!existsSync(output_dir)) {
  mkdirSync(output_dir);
}

console.log(`Generating Arrays...`);
for (const { metaType, type, Type, size } of config.arrays) {
  const output = template
    .replaceAll("{{metaType}}", metaType)
    .replaceAll("{{type}}", type)
    .replaceAll("{{Type}}", Type)
    .replaceAll("{{size}}", size.toString());

  const filename = `${Type}Arr.sol`;
  writeFileSync(path.join(output_dir, filename), output);
  console.log(`• Succesfully Generated ${filename}`);
}

const barrel_output_dir = "src/Scale/";
let output = `
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20; \n
`;
for (const { Type } of config.arrays) {
  output += `import { ${Type}Arr } from "./Array/${Type}Arr.sol"; \n`;
}

const filename = `Array.sol`;
writeFileSync(path.join(barrel_output_dir, filename), output);
console.log(`• Succesfully Generated ${filename}`);
