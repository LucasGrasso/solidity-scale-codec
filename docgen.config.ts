import type { DocgenConfig } from "solidity-doc-generator";

export default {
  outDir: "docs",
  sourceDir: "src",
  buildInfoDir: "artifacts/build-info",
  exclude: ["**/*.t.sol", "**/test/**"],
  generateVitepressSidebar: true,
  siteTitle: "Solidity Scale Codec",
  siteDescription: "Smart contract documentation for solidity-scale-codec",
  vitepressBasePath: "/solidity-scale-codec/",
  frontmatter: {
    author: "LucasGrasso",
    license: "Apache-2.0",
  },
} satisfies DocgenConfig;
