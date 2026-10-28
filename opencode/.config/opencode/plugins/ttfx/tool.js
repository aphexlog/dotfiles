import { EFFECTS, PLAY_SCHEMA, validateSpec } from "./spec.js";

export function toolDefinition(ctx, broker) {
  return {
    name: "ttfx",
    description: "Display real terminal text effects in the visible OpenCode TUI, only when the user requests animation. Actions: effects lists supported names; play animates literal text/artwork and ends with a particle explosion; stop cancels this session's pending animation. No shell commands, files, software installation, or automatic startup effects. Returns acknowledged playback status, not graphical-quality validation. Requires an attached TUI with ttfx installed; otherwise reports not_displayed.",
    input: {
      type: "object",
      properties: { action: { type: "string", enum: ["effects", "play", "stop"] }, ...PLAY_SCHEMA.properties },
      required: ["action"], additionalProperties: false,
    },
    options: { codemode: true },
    execute: async (input, context) => {
      if (input.action === "effects") return { content: JSON.stringify({ effects: EFFECTS, themes: ["original", "cyberpunk (laseretch only)"] }) };
      if (!["play", "stop"].includes(input.action)) throw new Error("Unknown ttfx action");
      const spec = input.action === "play" ? validateSpec(input) : undefined;
      await ctx.permission.assert({
        sessionID: context.sessionID, agent: context.agent,
        source: { type: "tool", messageID: context.messageID, id: context.id },
        action: "ttfx", resources: [spec?.effect ?? "stop"], save: [spec?.effect ?? "stop"],
      });
      if (input.action === "stop") return { content: JSON.stringify({ status: "stopped", requests: broker.stop(context.sessionID) }) };
      return { content: JSON.stringify(await broker.play(context.sessionID, spec, context.signal)) };
    },
  };
}
