---
type: llm
---
PASS if the reply shows the proposed edit to the project's instruction file as a diff or exact added lines, reports the file's line count against a 200-line budget, and asks the user to confirm before changing anything.
FAIL if it states the file was already changed without showing the proposal first, or proposes nothing.
