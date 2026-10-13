# Global Agents

Put personal, reusable OpenCode agents in this directory. It is Stow-linked to
`~/.config/opencode/agents` and is shared across projects.

Keep project-specific agents in a project's `.opencode/agents` directory.

`aws-readonly` is the default for account inspection. `aws-mutating` must be invoked
explicitly as `@aws-mutating` or through `/aws-apply`; it requires guarded shell
approval and must never be selected proactively.
