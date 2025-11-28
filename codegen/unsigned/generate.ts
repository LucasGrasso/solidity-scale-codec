import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import path, { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const config = JSON.parse(
  readFileSync(path.join(__dirname, "config.json"), "utf-8")
);
const template = readFileSync(
  path.join(__dirname, "Unsigned.sol.template"),
  "utf-8"
);

const output_dir = "src/Scale/Unsigned/";
if (!existsSync(output_dir)) {
  mkdirSync(output_dir);
}

console.log(`Generating Unsigned...`);
for (const { type, Type, size, asmDecodeAt, LE } of config.unsigned) {
  const output = template
    .replaceAll("{{type}}", type)
    .replaceAll("{{Type}}", Type)
    .replaceAll("{{size}}", size.toString())
    .replaceAll("{{asmDecodeAt}}", asmDecodeAt)
    .replaceAll("{{LE}}", LE);

  const filename = `${Type}.sol`;
  writeFileSync(path.join(output_dir, filename), output);
  console.log(`• Succesfully Generated ${filename}`);
}
