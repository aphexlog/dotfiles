# Local model memory and management

## Remember

- The user has a local Qwen3.8 Flash Next abliterated model configured for OpenCode
  on host SOL. They stopped it because approximately 7–8 tokens/second was too slow.
  Do not silently restart it or prefer it over a cloud model.
- Read `~/.local/share/local-llm/inventory.md` when managing local models. It records
  model IDs, service names, paths, performance, and the user's preferences.
- Verify the inventory against current OpenCode configuration, installed manifests,
  and user services. Historical state is not current state. On another machine,
  missing files do not authorize downloading or installing anything.

## Ask before choosing

- For requests such as "enable a local model", "disable the local model", "start",
  "stop", "load", or "unload" a local model, ask **which model** before changing
  anything, unless the user already named it unambiguously. Use the question tool
  to show installed models, even if only one is installed; include a short speed
  or memory caveat where relevant. Do not choose a model merely because it is the
  OpenCode default or the last model discussed.
- Distinguish starting/stopping inference now, login autostart, OpenCode's model
  catalog, and OpenCode's default/session selection. When "enable/disable" leaves
  the scope unclear, offer "now only" versus "also change login autostart".
  Explicit "start/stop" means runtime only unless the user says otherwise.
- Never download, uninstall, delete weights, change the default model, or alter
  autostart merely to satisfy a runtime start/stop request.

## Execute and verify

- Check the selected model's actual service and endpoint first. Do not run several
  large models concurrently or stop a different model without permission.
- Start: use the recorded user service, wait for API readiness with a bounded
  timeout, then explain how to select the model with `/models`. Do not switch this
  conversation's model automatically.
- Stop: stop the selected user service and verify it is inactive and its listener
  is gone. Preserve downloaded weights and provider registration.
- If a stopped model is still OpenCode's default or still enabled at login, say so.
  Ask before changing those settings or choosing a replacement cloud model.
- Update the inventory after authorized changes, recording the observation date
  and keeping runtime state separate from autostart and OpenCode selection.
- Status/inventory checks must not start the model or send an inference request.
