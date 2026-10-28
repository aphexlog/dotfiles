# Cyber-pirate login screen

SDDM's boot/logout greeter is separate from the `aphexlog.lock` session lock.
This theme matches that lock screen without depending on Quickshell or files
inside the user's home directory at login time.

Install `cyber-pirate/` into `/usr/local/share/sddm/themes/cyber-pirate/`, copying
`../plugins/aphexlog.lock/cyber-skull.svg` into the installed theme directory.
Install `zz-cyber-pirate.conf` into `/etc/sddm.conf.d/` to select it. Existing
authentication, autologin, and session settings are not changed.

Preview with `sddm-greeter-qt6 --test-mode --theme /usr/local/share/sddm/themes/cyber-pirate`.
Do not restart SDDM from a running desktop: that terminates the session.
The theme takes effect when the greeter next starts.

To revert, remove only `/etc/sddm.conf.d/zz-cyber-pirate.conf`; the existing
Omarchy theme selection is left intact underneath this override.
