import type { DocgenConfig } from "solidity-doc-generator";

export default {
  outDir: "docs",
  sourceDir: "src",
  buildInfoDir: "artifacts/build-info",
  exclude: ["**/*.t.sol", "**/test/**"],
  generateVitepressSidebar: true,
  siteTitle: "Solidity Scale Codec",
  siteDescription:
    "Complete API reference for SCALE codec implementation in Solidity",
  vitepressBasePath: "/solidity-scale-codec/",
  repository: "https://github.com/LucasGrasso/solidity-scale-codec",
  indexTemplate: "./templates/index.md",
  customDocsDir: "./guides",
  frontmatter: {
    author: "LucasGrasso",
    license: "Apache-2.0",
  },
  // Markdown Template Rendering (OpenZeppelin-style)
  templateDir: "./templates",
  useMarkdownTemplate: true,
} satisfies DocgenConfig;
