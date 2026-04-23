---
"solidity-scale-codec": major
---

Add barrel exports for v3 and v5, and rename conflicting structs. `TrapParams` in `XcmError` renamed to `TrapErrorParams` and `IndexParams` in `BodyId` renamed to `BodyIndexParams`

**Why**

For allowing barrel exports for easier imports.

**How you should update your code**
Rename the affected structs accordingly
