import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import path, { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const template = readFileSync(
  path.join(__dirname, "Bytes.sol.template"),
  "utf-8",
);

const output_dir = "src/Scale/Bytes/";
if (!existsSync(output_dir)) {
  mkdirSync(output_dir);
}

const sizes = [2, 4, 8, 16, 32];

console.log(`Generating Bytes...`);
for (const size of sizes) {
  const output = template.replaceAll("{{n}}", size.toString());

  const filename = `Bytes${size}.sol`;
  writeFileSync(path.join(output_dir, filename), output);
  console.log(`• Succesfully Generated ${filename}`);
}

const barrel_output_dir = "src/Scale/";
let output = `
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28; \n
`;
for (const size of sizes) {
  output += `import { Bytes${size} } from "./Bytes/Bytes${size}.sol"; \n`;
}

const filename = `Bytes.sol`;
writeFileSync(path.join(barrel_output_dir, filename), output);
console.log(`• Succesfully Generated ${filename}`);
