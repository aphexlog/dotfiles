# Global OpenCode ttfx tool

Native OpenCode **V2** plugin: an agent-callable `ttfx` tool, a TUI player, and a
small RPC bridge using OpenCode's existing server. No MCP server, extra daemon,
model/provider changes, shell commands, downloads, or dependency installation.
It is independent of Daydream and available to any permitted agent.

## Use

Ask an agent:

> Use the ttfx tool to animate “HELLO WORLD” with laseretch and cyberpunk colors.

The model-facing tool accepts:

```json
{"action":"effects"}
{"action":"play","text":"HELLO WORLD","effect":"laseretch","theme":"cyberpunk"}
{"action":"stop"}
```

- `effects`: list the allowlisted ttfx 0.5 effect names without running anything.
- `play`: send literal text or multiline artwork to the matching **visible** TUI.
  Defaults: `laseretch`, `original` colors. `cyberpunk` colors apply to laseretch.
- `stop`: cancel this session's pending animation.

For direct use without a model request, open the command palette and choose
**Play ttfx text effect**, or use `/ttfx your text`. Choose an effect in the
dialog. `/ttfx-stop` or **Stop ttfx animation** dismisses playback.
These commands work on the home screen as well as inside sessions. No startup,
agent-selection, or first-message hooks run effects automatically.

## Appearance

The entrance is the **real installed ttfx engine**, not a simulated effect.
It runs at the same 120 FPS setting as Omarchy's screensaver. Original effect
defaults are retained unless the caller selects the cyberpunk laser palette.
After completion, text holds for 350 ms, then breaks into colored particles and
dissipates over approximately 660 ms. This short local particle outro is separate
from ttfx itself. Cancellation stops immediately rather than forcing an outro.

Only foreground glyphs/colors are rendered. The existing OpenCode background and
terminal transparency are inherited—no black rectangle or font installation.
The TUI uses explicit native `StyledText`/RGBA chunks, not nested span styles.
Rendered terminal output was checked for actual multicolor glyphs, in addition
to the engine's decoded colors and playback completion acknowledgement.
`reducedMotion: true` in plugin options displays static text without starting
ttfx or exploding it. `enabled: false` disables the plugin contributions.

## Installation and Stow

Requires an existing **ttfx 0.5 executable on the TUI machine's PATH**, and
OpenCode V2 with server/TUI/RPC plugin support. Tested against OpenCode 2.0.32.
Node.js 18+ is needed only to run the standalone tests; OpenCode supplies its
plugin UI runtime imports. No `npm install` is needed.

The Stow-managed global `opencode.json` registers this bundle explicitly:

```json
{
  "plugins": ["{env:HOME}/Code/dotfiles/opencode/.config/opencode/plugins/ttfx"]
}
```

This follows this repository's `~/Code/dotfiles` checkout convention. **If cloned
elsewhere, update that one path.** It intentionally points to the real bundle:
OpenCode's server rejects a plugin directory whose entrypoint resolves outside
its root, which happens with individual file symlinks from `stow --no-folding`.
No safety check or permission is relaxed to bypass that restriction.

From the dotfiles checkout, preview and apply the normal OpenCode package:

```sh
stow --simulate --verbose --no-folding --target "$HOME" \
  --ignore='(service\.json|opencode\.jsonc)$' opencode
stow --verbose --no-folding --target "$HOME" \
  --ignore='(service\.json|opencode\.jsonc)$' opencode
```

Review conflicts; never adopt or overwrite unrelated files. Restart the OpenCode
TUI to load its player. The server tool may appear after configuration reload,
but a tool's presence alone does not prove a compatible TUI is attached.

To configure options, replace the string entry with an object containing the
same `package` path and `options`, for example `{ "reducedMotion": true }`.
To disable without deleting source, use `{ "enabled": false }`. Do not change
model defaults or broaden permission rules just to enable animations.

## Permissions, limits, and honest outcomes

- `play`/`stop` evaluate the session/agent's existing `ttfx` permission action.
  Resources are the selected effect or `stop`. The plugin adds no allow rules,
  never auto-approves prompts, and propagates permission denial/cancellation.
- Text: at most 4000 characters, 120 columns, 24 lines. No tabs, ANSI escape
  sequences, or control characters. Artwork must fit the actual visible canvas;
  clipping is an explicit failure. Wide emoji/CJK layout has not been verified.
- A fixed executable and allowlisted effect are launched with `shell: false`;
  text goes over stdin. No file paths or arbitrary CLI flags are accepted.
- At most one pending tool request per session, 16 per location. A single visible
  TUI claims each request. Background sessions cannot steal focus or play effects.
- No claimant within 5 seconds returns **`not_displayed`**. A claimed player must
  report real frames and completion; absence of acknowledgement is not success.
  Tool output includes `framesReceived`, not a claim about graphical quality.
- Engine playback is capped at 30 seconds, with a 35-second broker watchdog.
  Looping/long effects may hit that limit. Missing ttfx or incompatible output
  reports failure; no imitation fallback or automatic installation.
- Stop, resize, route change, tool cancellation, and unload terminate only the
  owned child, escalating to SIGKILL after 500 ms if needed. Buffered frames and
  particle counts are bounded. No `pkill`, raw terminal cursor controls, or
  background-color escape sequences reach OpenCode's terminal.
- Playback requests are transient RPC events; the plugin does not persist their
  text. Normal OpenCode tool calls/results remain part of session history. Never
  submit secrets as decorative text. Remote-server text uses OpenCode's existing
  connection; no external service or listening port is introduced.
- Headless runs, Mini, GUI, and browser clients without this TUI player cannot
  display effects. Remote TUIs need the local player and local ttfx installed.

## Validation

```sh
node --test opencode/.config/opencode/plugins/ttfx/tests/core.test.mjs
TTFX_BIN=/usr/bin/ttfx node --test opencode/.config/opencode/plugins/ttfx/tests/core.test.mjs
```

Tests cover validation, background/control stripping, RPC location and Promise
contracts, permission denial, single-client claims, headless outcomes, aborts,
process ownership, reduced motion, and the explosion outro. Real-engine checks
exercise laseretch, rain, and beams; the full allowlist is not visually certified.

The native tool was also called end-to-end against a fresh installed OpenCode
TUI: `laseretch` with cyberpunk colors returned `completed` with
`framesReceived: true`. That confirms tool → RPC → local engine → TUI → completion
acknowledgement, not human aesthetic review of every effect/font.

References: [V2 server plugins](https://opencode.ai/v2/docs/build/plugins/server),
[TUI plugins](https://opencode.ai/v2/docs/build/plugins/cli), and
[RPC contracts](https://opencode.ai/v2/docs/build/plugins/rpc).
