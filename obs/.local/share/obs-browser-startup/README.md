# OBS Browser Startup Workaround

OBS Studio 32.2.2 can restore custom browser docks before CEF is initialized,
causing `CefTask_0_CToCpp called with invalid version -1`. This local OBS
plugin initializes CEF through OBS's existing browser-panel API during
`obs_module_post_load`, before layout restoration. It waits at most 20 seconds.

## Build and Install

After stowing the `obs` package, run:

```sh
obs-browser-startup-build
```

The script compiles against the installed libobs and Qt 6 Widgets libraries,
using temporary files in `${XDG_CACHE_HOME:-~/.cache}/obs-browser-startup`.
It atomically installs the plugin at:

`~/.config/obs-studio/plugins/browser-startup-guard/bin/64bit/browser-startup-guard.so`

`XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, and `CXX` are supported.
The installed module takes effect on the next OBS launch. A successful startup
logs `[browser-startup-guard] Browser ready before dock restoration: yes`.

## Upstream API Header

`browser-panel.hpp` is vendored unchanged from OBS 32.2.2's obs-browser submodule:

- Repository: https://github.com/obsproject/obs-browser
- Commit: `3f0a2cdf378939ebe3c6f9ab36d4ea100c25aac2`
- Path: `panel/browser-panel.hpp`
- Source: https://github.com/obsproject/obs-browser/blob/3f0a2cdf378939ebe3c6f9ab36d4ea100c25aac2/panel/browser-panel.hpp
- Upstream license: GNU GPL version 2; included in `COPYING`.

The local plugin uses the matching panel API to initialize the installed browser
engine; it does not vendor the browser engine itself.

## Maintenance

Rebuild after OBS or Qt updates. Review this workaround and its pinned API header
when changing OBS/browser-plugin versions. Once upstream fixes the startup issue,
quit OBS and remove the installed `browser-startup-guard` plugin directory.
