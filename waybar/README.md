# Athena-inspired Waybar for Omarchy

Rounded floating capsules, Pac-Man/ghost workspaces with application icons, and
hover drawers, adapted from [Athena](https://github.com/haikal-hakim/athena).
The original design is MIT-licensed; attribution is retained in `LICENSE`.

## What stays Omarchy

Menus, launcher, audio/network/Bluetooth/power panels, notification daemon and
history, stay-awake control, lock screen, keyboard shortcuts, and wallpaper
management continue using Omarchy. No Rofi, SwayNC, or replacement shell is
installed. Only the visible status bar is replaced; the original bar stays
loaded so its panel services and shortcuts still work.

Matugen themes **only Waybar**, using the existing Omarchy wallpaper. Other
application themes and the wallpaper are not changed. Generated CSS lives in
`~/.cache/athena-waybar/`, never in the repository. A systemd path unit regenerates
it when Omarchy changes the current wallpaper or theme.

## Install

```bash
omarchy pkg add waybar matugen
cd ~/Code/dotfiles
stow --target "$HOME" --ignore='(^|/)(LICENSE|README\.md)$' waybar matugen
systemctl --user daemon-reload
athena-bar enable
```

In `~/.config/hypr/bindings.lua`, route the existing bar shortcut to the active
bar without changing any other bindings:

```lua
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + SHIFT + SPACE", "Toggle top bar", "$HOME/.local/bin/athena-bar toggle")
```

Validate Hyprland edits with `hyprctl reload` and `hyprctl configerrors`.

## Controls

- Arch icon: Omarchy menu; hover to reveal app shortcuts.
- Workspaces: click to switch; left monitor uses 1–5, right uses 6–9 and 0.
- Gear / `Super+Ctrl+D`: desktop controls for window selection, moving, resizing,
  floating/tiling, display scaling and quick settings.
- Power: Omarchy power panel; right-click for the system menu.
- Light bulb: Omarchy's native stay-awake toggle (idle lock is not disabled by default).
- YouTube Music and Apple Music: large icon-only buttons; click to expand their
  matching compact players. Each uses its own browser bridge for track details
  and playback; hover for song information.
- Apple Music: right-click to play/pause, scroll to
  skip, or middle-click to open the web app. Sign in and play a song once to
  connect. The player lives in `omarchy/.config/omarchy/plugins/aphexlog.apple-music`.
- Microphone: default input name and live waveform before agent usage; click for
  audio settings, right-click to mute. Follows input changes automatically and
  never saves audio. The meter keeps the microphone open while unmuted.
- Volume/network/Bluetooth: existing Omarchy panels; hover for extra controls.
- Wi-Fi: signal-strength icon only; hover to see the network name, signal, and IP.
- Clock: local system time, not Athena's hard-coded timezone; right-click for calendar.
- Bell: Omarchy notification history; right-click toggles Do Not Disturb.
- `Super+Shift+Space`: hide/show Waybar, or the stock bar if Waybar is stopped.

The workstation has no battery, so no battery percentage is fabricated. The
temperature module uses its existing ACPI thermal zone. Monitor DP-7 receives a
slightly smaller font for the portrait display; adjust this selector for another
monitor arrangement.

### Desktop controls through chat

The OpenCode `desktop.state` and `desktop.control` tools share the
`~/.local/bin/cyber-desktop` backend with the gear panel. Use `/desktop` or ask
directly, for example: “move this window to the right monitor” or “set volume
to 35%.” Inspect live window addresses before targeting a particular window.

Display scaling saves hardware-identified rules in
`~/.config/hypr/desktop-controls.lua`, loaded after the machine's monitor layout.
Failed application restores the previous file; disconnected displays retain
their saved rules. Position and rotation are preserved.

### Cyberpunk popups

Bar clicks use `cyber-bar-popup` to snapshot the pointer's monitor and horizontal
position before opening a panel. Top-bar cards open below the button; the right
monitor's bottom-bar cards open above it, clamped to the screen edges. Rotated
and scaled displays use logical coordinates. Direct toggles and app launchers
keep their original actions; third-party tray apps own their own menus.

`aphexlog.hud` supplies the shared navy/cyan/magenta frame and a single anchored
notification history panel. Audio, network, Bluetooth, and power use user-owned
Omarchy clones, never edited packaged files. The local bar, menu, calendar, usage,
and YouTube/Apple Music plugins use the same popup components. Outside-click/Escape
dismissal and one-popup-at-a-time handoff are retained.

## Recovery and maintenance

```bash
athena-bar stock    # Stop/disable Athena and restore the prior stock-bar visibility
athena-bar enable   # Enable Athena again, including automatic recoloring
athena-bar colors   # Manually regenerate colors from the current wallpaper
athena-bar status
```

The service restores the original bar if Waybar exits, and retries failures at
most three times per minute. Existing Omarchy files under `/usr/share/omarchy/`
are never modified. This is a user-maintained configuration; future changes to
Omarchy's panel IPC or Waybar's modules may need updates here.
