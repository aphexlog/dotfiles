# OBS Studio

Cyberpunk OBS appearance and browser docks for PhxCast.

## Install

Requires GNU Stow, OBS Studio, the OBS browser plugin with its matching CEF
runtime, a C++ compiler, `pkg-config`, and Qt 6 Widgets/libobs development files.
On Arch, the build dependencies are provided by `gcc`, `pkgconf`, `qt6-base`,
and `obs-studio`. The dock headers use JetBrainsMono Nerd Font with a monospace
fallback.

```sh
cd ~/Code/dotfiles
stow --no-folding --target "$HOME" obs
obs-browser-startup-build
update-desktop-database "$HOME/.local/share/applications"
```

Back up conflicting live files before stowing, as described in the root README.
Use `--no-folding` so the OBS configuration and plugin directories remain real
directories for local application state.

The desktop launcher sets `QT_QPA_PLATFORM=xcb`, `GDK_BACKEND=x11`, and
`OZONE_PLATFORM=x11`: OBS 32.2.2 needs XWayland for browser docks on this setup.

## PhxCast Cyberpunk Theme

Select **PhxCast Cyberpunk**, a Yami variant, under **Settings → Appearance**.
Its theme ID is `com.phxcast.Yami.Cyberpunk`.

The theme provides dark navy panels, cyan borders and faders, magenta accents,
and terminal-style dock headers. Source:
`.config/obs-studio/themes/PhxCast_Cyberpunk.ovt`.

## Twitch Docks

Add these under **Docks → Custom Browser Docks**:

| Dock name | URL |
| --- | --- |
| PhxCast Chat | `https://www.twitch.tv/popout/phxcast/chat?popout=&darkpopout` |
| PhxCast Stream Stats | `https://www.twitch.tv/popout/phxcast/dashboard/live/stats` |

Sign in to Twitch inside OBS. Its browser session is separate from Chromium's.
The top person-icon row in Stream Stats shows live viewers while streaming and
**Offline** otherwise. Use the dock's pop-out button for a separate window.

## Browser Startup Workaround

The local `browser-startup-guard` plugin initializes CEF before OBS restores
browser docks. It avoids the observed startup failure:
`CefTask_0_CToCpp called with invalid version -1`.

The repository contains source, the matching upstream panel API header, and a
build/install script. The compiled plugin is generated for the local machine.
See [.local/share/obs-browser-startup/README.md](.local/share/obs-browser-startup/README.md)
for provenance and removal instructions.

Verified on SOL on 2026-11-12:

| Package | Version |
| --- | --- |
| `obs-studio` | `32.2.2-1` |
| `obs-studio-plugin-browser` | `32.2.2-1` |
| `cef` | `151.3.17-1` |

That browser plugin reports Chromium `151.0.7922.138` for both compiled and
runtime CEF. CEF `152.0.6-1` caused crashes with that plugin build. Check the
compiled/runtime CEF versions in OBS's log when reproducing this setup with
different packages. Rebuild the local guard after OBS or Qt updates.

## Local Application State

OBS owns its theme selection, dock placement, scene collections, device paths,
profiles, stream keys, login cookies, and logs. Those remain machine-local;
the package tracks the reusable theme, launcher, and workaround source.
