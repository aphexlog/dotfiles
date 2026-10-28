import importlib.util
import json
import os
from pathlib import Path
import select
import struct
import subprocess
import tempfile
import time
import unittest

HOST = Path(__file__).resolve().parents[1] / "bridge/host.py"
spec = importlib.util.spec_from_file_location("apple_bridge", HOST)
host = importlib.util.module_from_spec(spec)
spec.loader.exec_module(host)


class BridgeTests(unittest.TestCase):
    def test_protocol_rejects_unknown_actions_and_invalid_values(self):
        for command in [{"cmd": "exec", "value": "ignored"}, {"cmd": "volume", "value": 2},
                        {"cmd": "seek", "value": -1}, {"cmd": "seek", "value": float("nan")}]:
            with self.assertRaises(ValueError):
                host.clean_command(command)

    def test_native_host_and_fifo_exchange_apple_state_and_commands(self):
        with tempfile.TemporaryDirectory(prefix="apple-bridge-", dir="/tmp/opencode") as directory:
            env = {**os.environ, "XDG_STATE_HOME": directory}
            process = subprocess.Popen(["python3", str(HOST)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, env=env)
            try:
                message = json.dumps({"type": "state", "state": {
                    "title": "Apple song <literal>", "playing": True, "position": 5,
                    "duration": 100, "queue": [{"title": "Next song", "artist": "Artist"}]
                }}).encode()
                process.stdin.write(struct.pack("<I", len(message)) + message)
                process.stdin.flush()
                state = Path(directory) / "apple-music-player/state.json"
                deadline = time.monotonic() + 3
                while not state.exists() and time.monotonic() < deadline:
                    time.sleep(0.02)
                data = json.loads(state.read_text())
                self.assertEqual(data["service"], "apple-music")
                self.assertEqual(data["title"], "Apple song <literal>")
                self.assertTrue(data["playing"])
                subprocess.run(["python3", str(HOST), "--send", '{"cmd":"volume","value":0.4}'],
                               check=True, env=env, capture_output=True, timeout=3)
                self.assertTrue(select.select([process.stdout], [], [], 3)[0])
                length, = struct.unpack("<I", process.stdout.read(4))
                self.assertEqual(json.loads(process.stdout.read(length)), {"cmd": "volume", "value": 0.4})
                process.stdin.close()
                self.assertEqual(process.wait(timeout=3), 0)
                self.assertFalse(json.loads(state.read_text())["connected"])
            finally:
                if process.poll() is None:
                    process.terminate()
                    process.wait(timeout=3)
                process.stdout.close()


if __name__ == "__main__":
    unittest.main()
