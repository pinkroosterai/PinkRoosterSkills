---
type: llm
---
PASS if the reply reports the instruction file's line count against a 200-line budget, lists any proposed removals or changes as numbered items (or says nothing needs changing), and names only commands or scripts that exist in the repository.
FAIL if it cites a command or script that does not exist in the repository, changes a file, or gives no line count.
