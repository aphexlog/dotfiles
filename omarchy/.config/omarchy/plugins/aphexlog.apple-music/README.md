# Apple Music toolbar player

Apple Music mini-player with the same compact cover, track, progress, playback,
volume and queue layout as YouTube Music. Uses the shared `aphexlog.hud` popup,
including top/bottom toolbar positioning on both monitors.

- Click the Apple Music button for artwork, track details and playback controls.
- Right-click to play/pause; scroll up/down for previous/next; middle-click to open
  Apple Music directly.
- Open Apple Music launches/focuses the web app in Chromium's Personal profile.
  Sign in and start a song once to populate its player.
- Seeking, shuffle, repeat and volume control Apple Music itself. Queue expands
  below the player. Controls follow the connected player's capabilities.

The installed Music Players browser bridge sends Apple Music's own page state
through `apple_music_player.bridge`, independently of YouTube Music. It checks
the open Apple page once per second, with a four-second heartbeat; this uses no
extra web requests and never reads authentication tokens. Local state and the
command FIFO live in `~/.local/state/apple-music-player/` with private permissions.
Chromium's shared MPRIS session cannot identify its service when artwork is a
temporary file, so it is never borrowed as an unidentified fallback. Cider and
positively identified Apple MPRIS sessions remain supported.
Artwork is loaded from Apple's HTTPS image CDN only while the popup is open.
Library, search, queue editing and lyrics are available in the full web app.

## Installation

Link this directory into `~/.config/omarchy/plugins/aphexlog.apple-music` along
with `aphexlog.hud`, and add `{"id":"aphexlog.apple-music"}` to the bar layout
in `~/.config/omarchy/shell.json`. The dotfiles' Waybar configuration includes
the matching button. The existing unpacked extension at
`~/.config/omarchy/plugins/dqckey.ytmusic-player/bridge/extension` includes
`apple-background.js`, `apple-content.js` and `apple-page.js`, plus Apple-specific
site access. Its native-host registration points to this plugin's `bridge/host.py`.
Reload the extension with `dqckey.ytmusic-player/bin/ytmusic-cmd reload` after
editing its scripts. Reload the bar with:

```sh
omarchy-shell shell rescanPlugins
systemctl --user kill --kill-whom=main --signal=SIGUSR2 athena-waybar.service
```

## Checks and IPC

```sh
node --test tests/media-utils.test.cjs
python3 tests/bridge.test.py
omarchy-shell apple-music-player status
omarchy-shell apple-music-player state
omarchy-shell apple-music-player toggle
omarchy-shell apple-music-player next
omarchy-shell apple-music-player previous
omarchy-shell apple-music-player launch
```
