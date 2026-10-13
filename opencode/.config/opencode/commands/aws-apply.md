---
description: Explicitly run one guarded AWS mutation through the aws-mutating agent.
agent: aws-mutating
subtask: true
---

The user explicitly invokes `aws-mutating` through `/aws-apply` for this operation:

$ARGUMENTS

Execute only that operation. Follow the agent's account verification, dry-run,
confirmation, mutation, and post-change verification workflow. Ask a focused question
instead of guessing when the target or desired result is ambiguous.
