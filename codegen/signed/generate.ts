import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import path, { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const config = JSON.parse(
  readFileSync(path.join(__dirname, "config.json"), "utf-8")
);
const template = readFileSync(
  path.join(__dirname, "Signed.sol.template"),
  "utf-8"
);

const output_dir = "src/Scale/Signed/";
if (!existsSync(output_dir)) {
  mkdirSync(output_dir);
}

console.log(`Generating Signed...`);
for (const { type, Type, SType, size } of config.signed) {
  const output = template
    .replaceAll("{{SType}}", SType)
    .replaceAll("{{type}}", type)
    .replaceAll("{{Type}}", Type)
    .replaceAll("{{size}}", size.toString())
    .replaceAll("{{bitsize}}", (size * 8).toString());

  const filename = `${Type}.sol`;
  writeFileSync(path.join(output_dir, filename), output);
  console.log(`• Succesfully Generated ${filename}`);
}
