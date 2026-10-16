# Installed local models

This is persistent operational memory, not a live status report. Check the actual
configuration, files, services, and endpoints before taking action. Keep this file
updated when models or their management settings change.

## User preferences

- Ask which installed model to manage when the user does not name one, even if
  there is currently only one option.
- The user found this Qwen model too slow for normal use and asked to stop it.
  Do not restart it, make it the preferred model, or replace it without permission.
- Runtime start/stop, login autostart, and OpenCode model selection are separate
  operations. Confirm ambiguous enable/disable scope rather than conflating them.

## Qwen3.8 Flash Next Abliterated — IQ3_S

| Item | Value |
| --- | --- |
| Host | SOL — Ryzen AI 9 HX 370, Radeon 890M, approximately 96 GB RAM |
| Display name | Qwen3.8 Flash Next Abliterated (local) |
| OpenCode ID | `local/qwen3.8-flash-next-abliterated` |
| Optional variants | `#fast` disables thinking; `#deep` requests xhigh effort |
| API model ID | `qwen3.8-flash-next-abliterated` |
| Source | `SC117/Qwen3.8-Flash-Next-GSQ-RCO-abliterated-GGUF` |
| Quantization/download | IQ3_S; two verified GGUF shards, approximately 84 GB total |
| Runtime | llama.cpp b11669 / v0.7.0, Vulkan, selective CPU offload |
| User service | `local-llm.service` |
| API/health | `http://127.0.0.1:8080/v1` / `http://127.0.0.1:8080/health` |
| Data and setup | `~/.local/share/local-llm/` |
| Weights | `~/.local/share/local-llm/models/IQ3_S/` |
| Launch script | `~/.local/share/local-llm/start-server` |
| Unit file | `~/.config/systemd/user/local-llm.service` |
| Provider/default config | `~/.config/opencode/opencode.json` |
| Provenance/checksums | `~/.local/share/local-llm/manifest.json` |
| Full setup guide | `~/.local/share/local-llm/README.md` |
| Stow ownership | `~/Code/dotfiles/local-llm/`; provider config is in the `opencode` package |
| Validation | API tools/streaming passed; OpenCode fixed a bug and passed 3 tests |
| Observed speed | Approximately 7–8 generated tokens/second on short requests |
| Context | 65,536 tokens; one slot; 15-minute idle model unload |

### Last verified state — 2026-10-16

- Runtime: **stopped/inactive**, at the user's request because it was too slow.
- Login autostart: **enabled**; stopping it did not disable startup at next login.
- OpenCode configured default: still `local/qwen3.8-flash-next-abliterated`.
  Existing sessions may instead have a cloud model selected. Do not infer session
  selection from the configured default.
- Weights and provider entry: retained. Restarting does not need another download.
- Configurations, scripts, this inventory, and the manifest are Stow symlinks into
  the dotfiles repository. Weights, binaries, and generated results remain in the
  machine-local data directory. The Stow migration did not start the model or
  change autostart, inference settings, or the OpenCode default.

### Operations after the user selects this model and scope

```sh
# Inspect without waking the model.
systemctl --user show local-llm.service -p ActiveState -p SubState -p UnitFileState

# Runtime only.
systemctl --user start local-llm.service
systemctl --user stop local-llm.service

# Persistent login behavior: only when explicitly requested/confirmed.
systemctl --user enable --now local-llm.service
systemctl --user disable --now local-llm.service
```

After starting, verify `/health` and use OpenCode's `/models` selector for an
existing session. After stopping, verify the service is inactive and port 8080
has no listener. Do not remove weights or broaden permissions to manage the model.

## Adding other models

Add an entry with its exact OpenCode/API IDs, service, endpoint, weights, launch
configuration, measured performance, and verification date. Discover installed
models first; installing an unlisted model requires a separate user request.
