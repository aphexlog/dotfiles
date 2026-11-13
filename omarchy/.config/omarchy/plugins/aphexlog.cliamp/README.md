# Cliamp toolbar player

Cliamp mini-player in the shared Midnight Circuit popup, backed by Cliamp's
native MPRIS session. Track details, playback state, seeking, and player volume
follow the running app on both monitors.

- Click the amber music note to open the mini-player.
- Right-click to play/pause; scroll up/down for previous/next.
- Middle-click or **Open Cliamp** launches/focuses its terminal window.
- Space toggles playback inside the popup; Escape or an outside click closes it.
- Hover over the toolbar icon for the current track and artist.
- The icon turns amber only while playing; paused and closed states stay neutral.

Only `org.mpris.MediaPlayer2.cliamp` sessions are controlled. The widget does not
start playback on login. It uses the installed app icon without artwork downloads.
Library browsing, radio selection, playlists, EQ, shuffle, and repeat remain
available in Cliamp's terminal interface.

## Installation

Link this directory into `~/.config/omarchy/plugins/aphexlog.cliamp` alongside
`aphexlog.hud`, and add `{"id":"aphexlog.cliamp"}` to `bar.layout.right` in
`~/.config/omarchy/shell.json`. The dotfiles' Waybar music group includes its
matching button and uses the existing `aphexlog.bar` popup router.

```sh
omarchy-shell shell rescanPlugins
systemctl --user kill --kill-whom=main --signal=SIGUSR2 athena-waybar.service
```

## Checks and IPC

```sh
node --test tests/media-utils.test.cjs
omarchy-shell cliamp-player status
omarchy-shell cliamp-player state
omarchy-shell cliamp-player toggle
omarchy-shell cliamp-player next
omarchy-shell cliamp-player previous
omarchy-shell cliamp-player launch
```
