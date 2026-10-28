#!/usr/bin/env python3
"""Apple Music's local native-messaging bridge; no credentials or web requests."""

import json
import math
import os
from pathlib import Path
import stat
import struct
import sys
import threading
import time

STATE_DIR = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "apple-music-player"
FIFO = STATE_DIR / "cmd"
MAX_MESSAGE = 256 * 1024
COMMANDS = {"toggle", "resume", "pause", "next", "previous", "seek", "volume", "shuffle", "repeat", "inspect"}


def clean_command(message):
    if not isinstance(message, dict) or message.get("cmd") not in COMMANDS:
        raise ValueError("Unknown Apple Music command")
    result = {"cmd": message["cmd"]}
    if message["cmd"] in ("seek", "volume"):
        value = message.get("value")
        maximum = 1 if message["cmd"] == "volume" else 86400
        if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or not 0 <= value <= maximum:
            raise ValueError("Invalid Apple Music command value")
        result["value"] = value
    return result


def text(value, limit=512):
    return str(value or "")[:limit].replace("\x00", "")


def number(value, maximum):
    return max(0, min(maximum, value)) if isinstance(value, (int, float)) and math.isfinite(value) else 0


def clean_state(message):
    if not isinstance(message, dict):
        raise ValueError("Expected Apple Music state")
    result = {"service": "apple-music", "connected": True, "ts": time.time()}
    for key in ("title", "artist", "album", "error"):
        result[key] = text(message.get(key))
    result["art"] = text(message.get("art"), 2048)
    for key in ("playing", "canPlay", "canNext", "canPrevious", "canSeek", "canVolume", "canShuffle", "canRepeat", "shuffle"):
        result[key] = message.get(key) is True
    result["repeat"] = text(message.get("repeat"), 12)
    result["position"] = number(message.get("position"), 86400)
    result["duration"] = number(message.get("duration"), 86400)
    result["volume"] = number(message.get("volume"), 1)
    queue = message.get("queue", [])
    result["queue"] = [{key: text(item.get(key)) for key in ("title", "artist")}
                       for item in queue[:100] if isinstance(item, dict)] if isinstance(queue, list) else []
    return result


def write_json(name, value):
    path = STATE_DIR / name
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(value))
    os.replace(temporary, path)


def send_command(message):
    command = clean_command(message)
    if not stat.S_ISFIFO(FIFO.stat().st_mode):
        raise ValueError("Apple Music bridge is not connected")
    fd = os.open(FIFO, os.O_WRONLY | os.O_NONBLOCK)
    try:
        os.write(fd, (json.dumps(command) + "\n").encode())
    finally:
        os.close(fd)


def forward_commands():
    fd = os.open(FIFO, os.O_RDWR)
    pending = b""
    while True:
        pending += os.read(fd, 4096)
        if len(pending) > 8192:
            pending = b""
        while b"\n" in pending:
            line, pending = pending.split(b"\n", 1)
            try:
                message = clean_command(json.loads(line))
            except (ValueError, TypeError):
                continue
            encoded = json.dumps(message).encode()
            sys.stdout.buffer.write(struct.pack("<I", len(encoded)) + encoded)
            sys.stdout.buffer.flush()


def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--send":
        try:
            send_command(json.loads(sys.argv[2]))
        except (ValueError, OSError) as error:
            print(json.dumps({"ok": False, "error": str(error)}))
            return 1
        print(json.dumps({"ok": True}))
        return 0
    os.umask(0o077)
    STATE_DIR.mkdir(mode=0o700, parents=True, exist_ok=True)
    if not FIFO.exists():
        os.mkfifo(FIFO, 0o600)
    if not stat.S_ISFIFO(FIFO.stat().st_mode):
        raise ValueError("Apple Music command path is not a FIFO")
    threading.Thread(target=forward_commands, daemon=True).start()
    try:
        while True:
            header = sys.stdin.buffer.read(4)
            if len(header) != 4:
                break
            length, = struct.unpack("<I", header)
            if length > MAX_MESSAGE:
                break
            payload = sys.stdin.buffer.read(length)
            if len(payload) != length:
                break
            try:
                message = json.loads(payload)
                if not isinstance(message, dict):
                    continue
                if message.get("type") == "state":
                    write_json("state.json", clean_state(message.get("state")))
                elif message.get("type") == "result":
                    write_json("result.json", {"ts": time.time(), "ok": message.get("ok") is True,
                                               "error": text(message.get("error"))})
                elif message.get("type") == "inspect":
                    write_json("inspect.json", message.get("data"))
            except (ValueError, TypeError):
                continue
    finally:
        write_json("state.json", {"service": "apple-music", "connected": False, "ts": 0})
    return 0


if __name__ == "__main__":
    sys.exit(main())
