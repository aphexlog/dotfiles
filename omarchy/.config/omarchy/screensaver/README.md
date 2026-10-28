# Jolly Roger screensaver

A bold text-art skull with an eyepatch and crossed cutlasses, separate from the
cyber-skull lock screen. The original
Omarchy `ttfx` engine runs a curated selection: **laseretch**, **beams**,
**decrypt**, **matrix**, **vhstape**, and **synthgrid**. The first pass plays them
in that order (lasers first); subsequent passes shuffle all six without an
immediate repeat. Each finished reveal holds for two seconds.

The text-art was rasterized from `jolly-roger.svg`, an original high-contrast
pirate emblem, not the lock screen's artwork. Effects use the
same cyan/magenta palette at 60 FPS. A private Foot terminal config displays it
on both landscape and portrait monitors without changing your default terminal.

## Use

- Start: `~/.local/bin/cyber-pirate-screensaver force`
- Windowed preview: `~/.local/bin/cyber-pirate-screensaver --preview`
- Timed preview: `PIRATE_PREVIEW_SECONDS=20 ~/.local/bin/cyber-pirate-screensaver --preview`
- Dismiss: move the pointer, press a key, click, or scroll.
- Previous graphical ghost ship: `~/.local/bin/cyber-pirate-screensaver --hologram`

The Omarchy menu's **System → Jolly Roger** entry launches it too.

## Integration

`aphexlog.idle` is an Omarchy-supported clone of `omarchy.idle`. Only its
screensaver launch command is changed; idle timing, stay-awake support, and
locking remain inherited. Compare this clone against the packaged idle service
after Omarchy updates to pick up upstream fixes.

The `org.omarchy.screensaver` Foot app ID preserves stock window rules,
idle-service tracking, and lock-time cleanup. The supervisor closes all its own
windows if one is dismissed or focus moves to another app. Workers terminate
only their own effect process; unrelated terminals are never killed. A runtime
lock prevents duplicate instances. No session-lock surface, password handling,
or idle inhibitor is implemented here. The screensaver is not a security barrier.

## Restore the stock screensaver

Run `omarchy plugin enable omarchy.idle` to restore the stock idle service.
Remove the `system.screensaver` override from
`~/.config/omarchy/extensions/omarchy-menu.jsonc` to restore the stock menu action.
The original ASCII branding and lock-screen plugin are unchanged.
