# Local model for OpenCode

Status: installed and validated, but last stopped at the user's request because
it was too slow. Model checksums, API tests, and end-to-end OpenCode tests passed.
As last checked on 2026-10-16, login autostart remains enabled and the local model
remains the configured default for new OpenCode sessions. Existing sessions keep
their selected model. Verify live state rather than treating this as a status probe.

Persistent model inventory and management preferences: `inventory.md` in this
directory. Global OpenCode instructions load
`~/.config/opencode/instructions/local-models.md` to consult that inventory and
ask which model to manage before an ambiguous enable/disable request.

## Stow ownership

Scripts, this guide, the inventory, manifest, and user unit are managed by the
`local-llm` Stow package in `~/Code/dotfiles/local-llm/`. The active OpenCode
provider configuration is managed by the `opencode` package. Live file paths
remain unchanged and are now symlinks to those package files.

The enclosing data directory remains a real directory. Model weights, runtime
binaries, generated test results, and caches stay there, outside Git. The Python
scripts explicitly use that live data path rather than their resolved source
directory, so Stow symlinks cannot redirect downloads or test output into Git.
Stowing alone does not install the runtime, download a model, or start a service.

## Model and runtime

- Model: `SC117/Qwen3.8-Flash-Next-GSQ-RCO-abliterated-GGUF`, `IQ3_S`.
- Both shards are required: 83,863,586,496 bytes in total.
- Model weights are in `models/IQ3_S/`; `manifest.json` pins their revision and SHA-256 hashes.
- Runtime: official llama.cpp `v0.7.0` / `b11669`, Linux x64 Vulkan build.
- Hardware: Ryzen AI 9 HX 370, Radeon 890M, approximately 96 GB system RAM.
- Service: `~/.config/systemd/user/local-llm.service`.
- API: `http://127.0.0.1:8080/v1`; API model ID: `qwen3.8-flash-next-abliterated`.

The downstream repository advertises Apache-2.0, but the original model uses
the **Qwen Community License 1.0**. The upstream license is saved in
`models/LICENSE-Qwen-Community-1.0.txt`; consult it before commercial distribution
or providing a hosted model service.

## Memory and performance

`start-server` enables Vulkan, memory mapping, and lazy loading of the large
n-gram embedding table. GPU auto-fit reserves 4 GiB for desktop/runtime headroom
and places remaining weights on the CPU. The CPU and GPU share physical RAM.

The initial configuration uses 64K context, one inference slot, 12 CPU threads,
1024-token batches, 256-token microbatches, and F16 KV caches. Medium reasoning
is capped at 2048 thinking tokens. Prefix caching avoids reprocessing unchanged
conversation where supported. The server unloads the model after 15 minutes
without requests and reloads it on demand.

The service has a 70 GiB soft memory limit, an 80 GiB hard limit, and no swap
allowance. A larger model or context is not automatically a better coding agent.

## Commands

```sh
# Resume an interrupted download and verify every shard.
python ~/.local/share/local-llm/fetch-model.py

# Service management, once validation is complete.
systemctl --user start local-llm
systemctl --user stop local-llm
systemctl --user status local-llm
journalctl --user -u local-llm -n 80 --no-pager

# API, tool calling, and streaming smoke test.
python ~/.local/share/local-llm/test-api.py
```

The API binds only to loopback. llama.cpp's own filesystem/shell tools are not
enabled: OpenCode remains responsible for tool execution and permission checks.
Prompt logging is not enabled.

## Validation

- `api-test-results.json` records successful tool calls, tool-result round trips,
  and streamed responses. Initial short-request measurements were 29.7–31.4 prompt
  tokens/second and 7.3–8.3 generated tokens/second, not a long-context benchmark.
- The runtime reports 64K context and one slot. GPU use after loading was about
  41.9 GiB shared memory plus 1.9 GiB reserved VRAM; those share physical system RAM.
- `/tmp/opencode/local-llm-smoke/` contains a disposable Python repository with an
  arithmetic bug that OpenCode fixed. It read both files, edited only the
  implementation, ran the unchanged unit tests, and passed all three tests.
- `opencode-test-results.json` records the successful edit/test run in `fast`
  mode and a subsequent read/test run using the normal model configuration.
- The restrictive smoke agent initially denied a normal-mode command that
  appended an unapproved `echo`; a rerun with the exact permitted test command
  passed. No global tool permissions were broadened to accommodate the model.
- Existing OpenCode cloud providers, credentials, and AWS instructions are retained.

## OpenCode

The provider is registered globally in `~/.config/opencode/opencode.json` and is
available in `/models` as **Qwen3.8 Flash Next Abliterated (local)**. Select it
there to switch an already-open session; new sessions use it by default unless
a project configuration or an explicitly selected model overrides that default.

```sh
opencode run --model local/qwen3.8-flash-next-abliterated "Explain this repository"
opencode run --model 'local/qwen3.8-flash-next-abliterated#fast' "Explain this repository"
opencode run --model 'local/qwen3.8-flash-next-abliterated#deep' "Review this change carefully"
```

The normal model uses medium reasoning. `fast` disables thinking; `deep` requests
`xhigh` effort, still subject to the server's 2048-token reasoning budget. New
requests may take longer after idle unloading or when processing a large uncached
repository/tool prompt. The configured 64K context is intentionally below the
model's maximum to leave memory for the desktop and keep inference practical.

No BIOS, kernel boot parameters, system packages, or GPU memory allocation settings
are changed by this installation.
