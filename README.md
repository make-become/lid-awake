# Lid Awake

A [make become](https://make-become.github.io/) project.

Keeps a MacBook running with the lid closed, for one long job at a time. One switch in the menu bar, no Dock icon.

**Page:** https://make-become.github.io/lid-awake/ · **Details** (why it needs one permission, everything it puts on your Mac): https://make-become.github.io/lid-awake/details.html

## Install

```bash
curl -fsSL https://make-become.github.io/lid-awake/install.sh | sh
```

It downloads the latest release into `/Applications` (`~/Applications` if that is not writable), clears the download quarantine (the app is not notarised) and opens it. Read it first: [`docs/install.sh`](docs/install.sh).

## What it does

- **One switch**, *Stay on with the lid closed*, in the menu bar. The icon is a laptop while it is off and a sun while it is on.
- **A beep when the lid closes** while it is on, so you know the Mac did not go to sleep. Audible even when muted or at volume 0: the output is unmuted and raised to 75 % for the beep, then put back exactly as it was.
- **It never stays on by accident.** It turns itself off when the lid opens again, when you quit it, when it crashes or is force-quit (a small guard process waits for the app to exit), when the Mac restarts (a LaunchDaemon at boot), and when the app starts.
- **Languages:** English, Italiano, Español, Français, Deutsch (from the Mac's settings).

## The permission, and why this one

A MacBook sleeps when its lid closes unless `pmset -a disablesleep 1` is set (or it is a clamshell desktop with external display, power and keyboard). That setting needs root. The options were:

| Option | Why not / why |
|---|---|
| Ask for the password each time, or store it | Never: the app must not see or keep a password. |
| A privileged helper (`SMAppService` daemon + XPC) | A process running as root all the time, for one setting. It also needs a Developer ID certificate and notarisation to be approved; this app, like Claude Switcher, is ad-hoc signed. |
| **A one-line sudoers rule** (chosen) | Installed once, after macOS's own administrator dialog. It lets *your user* (by uid) run exactly `/usr/bin/pmset -a disablesleep 0` and `/usr/bin/pmset -a disablesleep 1` without a password. Any other `pmset` argument, or any other command, still needs the password. The app runs it with `sudo -n`, which never prompts. |

The first time you switch it on, the app explains this and macOS asks for the password. *Remove the permission…* in the menu takes it away again.

## Everything it puts on your Mac

| Where | What |
|---|---|
| `/Applications/Lid Awake.app` | The app. |
| `/etc/sudoers.d/lid-awake` | The rule above. Checked with `visudo -c` before it is installed (root:wheel, 0440). |
| `/Library/LaunchDaemons/com.makebecome.lid-awake.reset.plist` | Runs `pmset -a disablesleep 0` at boot, so a restart always gives normal sleep back. Not loaded at install time (it would reset the setting at once); it runs from the next boot. |
| Login items | Only with *Start at login* (`SMAppService.mainApp`). |

Uninstalling: *Remove the permission…*, quit, drag the app to the Trash.

## Build

```bash
./build.sh            # → build/Lid Awake.app (universal, ad-hoc signed) and build/Lid-Awake-macOS.zip
```

Needs macOS 13+ and the Xcode command line tools. `swift tools/make-icon.swift` regenerates the app icon.
`LidAwake --snapshot <dir>` renders the menu screenshots used on the page (`LID_AWAKE_LANG` chooses the language).
`LidAwake --beep` plays the lid-closed beep and prints the output volume and mute before, during and after.

## How it works

- **Lid:** IOKit's `IOPMrootDomain` property `AppleClamshellState` (true = closed). The app registers for the root domain's
  general-interest notifications and re-reads it on each one; a 5-second timer catches a missed notification.
- **State:** never remembered, always read from `pmset -g` (`SleepDisabled 1`): the icon re-reads it every 5 s and the menu on every open, and the beep and the auto-off check the real bit, so a change made from the Terminal is followed.
- **Beep:** CoreAudio on the default output device: unmute, raise the volume scalar to at least 0.75 (master element, or
  channels 1 and 2), play `/System/Library/Sounds/Glass.aiff` twice, restore volume and mute.
- **Guard:** at start the app launches its own binary as `LidAwake --guard <pid>`, which waits on a kqueue `NOTE_EXIT`
  for the app and then turns sleep back on. Works for Quit, crashes and Force Quit alike.

The code is in [`Sources/`](Sources/): [`Power.swift`](Sources/Power.swift) (pmset, lid, permission, guard),
[`Beep.swift`](Sources/Beep.swift), [`main.swift`](Sources/main.swift) (menu).

## Licence

MIT · [make become](https://make-become.github.io/), an artware studio.
