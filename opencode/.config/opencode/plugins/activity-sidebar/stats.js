// Count the latest execution, keeping steering messages inside the same turn.
export function latestActivity(messages = []) {
  let end = messages.length;
  let outcome;
  if (messages[end - 1]?.type === "idle") {
    outcome = messages[--end].outcome;
  }
  let start = end;
  while (start > 0 && messages[start - 1].type !== "idle") start--;

  const tools = new Map();
  let output = 0;
  let reasoning = 0;
  let hasUsage = false;
  for (let i = start; i < end; i++) {
    const message = messages[i];
    if (message.type !== "assistant") continue;
    if (message.tokens) {
      hasUsage = true;
      output += message.tokens.output;
      reasoning += message.tokens.reasoning;
    }
    for (const part of message.content) {
      if (part.type === "tool") tools.set(part.id, part.state.status);
    }
  }
  const states = [...tools.values()];
  return {
    calls: tools.size,
    running: states.filter((state) => state === "running" || state === "streaming").length,
    failed: states.filter((state) => state === "error").length,
    output,
    reasoning,
    hasUsage,
    outcome,
  };
}

export function activityLines(stats, status = "idle") {
  const state = status === "running" ? "Working"
    : stats.outcome === "failed" ? "Failed"
    : stats.outcome === "interrupted" ? "Interrupted"
    : stats.outcome === "succeeded" ? "Done" : "Idle";
  const number = (value) => value.toLocaleString("en-US");
  const lines = [state, `Tool calls  ${number(stats.calls)}`];
  if (stats.running && status === "running") lines.push(`Active      ${number(stats.running)}`);
  if (stats.failed) lines.push(`Failed      ${number(stats.failed)}`);
  if (stats.hasUsage) {
    lines.push(`Output      ${number(stats.output)} tokens`);
    if (stats.reasoning) lines.push(`Reasoning   ${number(stats.reasoning)} tokens`);
  }
  return lines.join("\n");
}
