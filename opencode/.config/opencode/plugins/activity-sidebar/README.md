# Activity sidebar

OpenCode V2 TUI plugin for live tool-call counts, active/failed calls, and reported
output/reasoning token usage in the right sidebar. Counts cover the latest
execution in the loaded transcript; steering messages do not reset them. Token
usage updates when the provider reports it, rather than estimating streamed text.

`cli.json` enables this TUI-only plugin and sets `session.thinking` to `show`,
`session.grouping` to `none`, `session.verbosity` to `high`, and `session.sidebar`
to `auto`. The transcript shows thinking and individual tool activity by default,
instead of the low-verbosity activity summaries. The verbosity setting is present
in OpenCode 2.3.0's implementation but missing from its published CLI settings
reference. OpenCode shows its sidebar when the terminal is wide enough;
Ctrl+X, then B toggles it.

The relative plugin path resolves beside `cli.json`. OpenCode supplies the runtime
imports; no dependency install or server component is needed. Settings hot-reload.
Use `/reload` if a running client has not picked up the plugin.

Remove the `./plugins/activity-sidebar` entry from `cli.json` to disable the
counters. Restore `thinking: "hide"` and `grouping: "auto"` to restore the compact
tool display, and `verbosity: "low"` for collapsed activity summaries.
Other built-in sidebar sections and assistant footers are retained.
