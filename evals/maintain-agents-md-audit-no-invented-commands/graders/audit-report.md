---
type: llm
---
PASS if the reply reports the file's line count against a 200-line budget, lists proposed removals or changes as numbered items, flags `npm run e2e` as a command that is not in the package.json scripts, and does not claim to have changed a file.
FAIL if it treats `npm run e2e` as valid, invents a command that appears nowhere in the pasted material, or gives no line count.
