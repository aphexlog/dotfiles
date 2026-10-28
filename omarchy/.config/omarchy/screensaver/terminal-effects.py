#!/usr/bin/env python
"""Run the real Omarchy text effects on the Jolly Roger, with scoped cleanup."""

import fcntl
import json
import os
from pathlib import Path
import random
import select
import shutil
import signal
import subprocess
import sys
import tempfile
import termios
import time
import tty

##############################################################################
# Artwork and Curated Effects
##############################################################################

CONFIG = Path(__file__).resolve().parent
APP_ID = "org.omarchy.screensaver"
PALETTE = ["f275cf", "63f5ed", "e0f8f6"]
EFFECTS = {
    "laseretch": [
        "--etch-speed", "5", "--etch-delay", "1",
        "--laser-gradient-stops", "ffffff", "63f5ed", "f275cf",
        "--cool-gradient-stops", "ffffff", "63f5ed",
        "--spark-gradient-stops", "ffffff", "63f5ed", "f275cf", "060b13",
    ],
    "beams": ["--beam-gradient-stops", "ffffff", "63f5ed", "f275cf"],
    "decrypt": ["--typing-speed", "8", "--ciphertext-colors", "63f5ed", "f275cf", "71909e"],
    "matrix": [
        "--rain-time", "7", "--highlight-color", "e0f8f6",
        "--rain-color-gradient", "12343d", "63f5ed",
    ],
    "vhstape": [
        "--total-glitch-time", "360",
        "--glitch-line-colors", "ffffff", "63f5ed", "f275cf", "ffffff",
        "--glitch-wave-colors", "ffffff", "f275cf", "63f5ed", "ffffff",
    ],
    "synthgrid": ["--grid-gradient-stops", "12343d", "63f5ed", "f275cf"],
}


def effect_command(effect):
    gradient_flag = "--text-gradient-stops" if effect == "synthgrid" else "--final-gradient-stops"
    return [
        "ttfx", "-i", str(CONFIG / "jolly-roger.txt"),
        "--frame-rate", "60", "--canvas-width", "0", "--canvas-height", "0",
        "--reuse-canvas", "--anchor-canvas", "c", "--anchor-text", "c",
        "--terminal-background-color", "060b13", "--no-eol", "--no-restore-cursor",
        effect, *EFFECTS[effect], gradient_flag, *PALETTE,
    ]


def stop(process):
    if process is not None and process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def interrupted(_signal, _frame):
    raise SystemExit(0)


##############################################################################
# Terminal Worker
##############################################################################


def worker(ready):
    fd = sys.stdin.fileno()
    original = termios.tcgetattr(fd)
    effect = None
    try:
        # Wait until all monitor windows are placed and their PTYs are resized.
        while not ready.exists():
            time.sleep(0.05)
        tty.setcbreak(fd)
        sys.stdout.write("\033[?25l\033[?1003h\033[?1006h")
        sys.stdout.flush()
        armed_at = time.monotonic() + 0.7
        playlist = list(EFFECTS)
        last = None
        hold_until = 0
        while True:
            if select.select([fd], [], [], 0.05)[0]:
                data = os.read(fd, 4096)
                if not data or time.monotonic() >= armed_at:
                    return
            if effect is not None and effect.poll() is None:
                continue
            if effect is not None:
                if effect.returncode != 0:
                    raise RuntimeError(f"ttfx {last} exited with {effect.returncode}")
                effect = None
                hold_until = time.monotonic() + 2
            if time.monotonic() < hold_until:
                continue
            if not playlist:
                playlist = list(EFFECTS)
                random.shuffle(playlist)
                if playlist[0] == last:
                    playlist.append(playlist.pop(0))
            last = playlist.pop(0)
            effect = subprocess.Popen(effect_command(last), stdin=subprocess.DEVNULL)
    finally:
        stop(effect)
        termios.tcsetattr(fd, termios.TCSANOW, original)
        sys.stdout.write("\033[?1003l\033[?1006l\033[?25h\033[0m")
        sys.stdout.flush()


##############################################################################
# Multi-monitor Launcher
##############################################################################


def hypr(*args):
    return subprocess.check_output(["hyprctl", *args], text=True)


def focus(monitor):
    hypr("dispatch", "hl.dsp.focus({ monitor = " + json.dumps(monitor) + " })")


def launch(preview):
    for program in ("foot", "ttfx", "hyprctl"):
        if not shutil.which(program):
            raise RuntimeError(f"Required installed program not found: {program}")
    runtime = Path(os.environ["XDG_RUNTIME_DIR"])
    with (runtime / "cyber-pirate-screensaver.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        monitors = json.loads(hypr("monitors", "-j"))
        focused = next(m["name"] for m in monitors if m["focused"])
        app_id = "org.aphexlog.screensaver.preview" if preview else APP_ID
        processes = []
        seconds = float(os.environ.get("PIRATE_PREVIEW_SECONDS", "0"))
        deadline = time.monotonic() + seconds if seconds > 0 else float("inf")
        with tempfile.TemporaryDirectory(prefix="pirate-", dir=runtime) as stage:
            ready = Path(stage) / "ready"
            try:
                for monitor in ([m for m in monitors if m["focused"]] if preview else monitors):
                    focus(monitor["name"])
                    command = [
                        "foot", "--config", str(CONFIG / "foot.ini"), "--app-id", app_id,
                        "--title", "Jolly Roger // " + monitor["name"],
                    ]
                    if not preview:
                        command.append("--fullscreen")
                    command += [sys.executable, str(Path(__file__).resolve()), "--worker", str(ready)]
                    process = subprocess.Popen(command)
                    processes.append(process)
                    mapped = time.monotonic() + 5
                    while time.monotonic() < mapped:
                        windows = json.loads(hypr("clients", "-j"))
                        if any(w["pid"] == process.pid and w["class"] == app_id for w in windows):
                            break
                        if process.poll() is not None:
                            raise RuntimeError("Screensaver terminal exited before mapping")
                        time.sleep(0.05)
                    else:
                        raise RuntimeError("Screensaver terminal did not map within five seconds")
                focus(focused)
                ready.touch()
                while time.monotonic() < deadline and all(p.poll() is None for p in processes):
                    active = json.loads(hypr("activewindow", "-j"))
                    if active.get("class") != app_id:
                        break
                    time.sleep(0.25)
            finally:
                for process in processes:
                    stop(process)


if __name__ == "__main__":
    for sig in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP, signal.SIGQUIT):
        signal.signal(sig, interrupted)
    if len(sys.argv) > 1 and sys.argv[1] == "--worker":
        worker(Path(sys.argv[2]))
    else:
        launch("--preview" in sys.argv)
