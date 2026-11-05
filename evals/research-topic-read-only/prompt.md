---
description: "A chat-only research request must not start the corpus workflow or write anything."
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill, WebSearch, WebFetch]
tags: [natural, research-topic, should-not-trigger]
---
Research agent skill portability and give recommendations in chat only. Do not write files or create a corpus.
