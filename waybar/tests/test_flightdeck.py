"""Regression checks for shared focus sessions and literal task labels."""

import concurrent.futures
import importlib.machinery
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
LOADER = importlib.machinery.SourceFileLoader("flightdeck", str(ROOT / ".local/bin/cyber-flightdeck"))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
deck = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(deck)


class FlightDeckTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="flightdeck-test-")
        self.addCleanup(self.directory.cleanup)
        self.state = patch.object(deck, "STATE", Path(self.directory.name))
        self.state.start()
        self.addCleanup(self.state.stop)

    def test_shared_deadline_survives_reloads_and_claims_completion_once(self):
        with patch.object(deck.time, "time", return_value=1000):
            result = deck.update_timer({"action": "start", "minutes": 25, "label": "Ship the thing"})
        self.assertEqual(result["timer"]["remaining"], 1500)
        self.assertEqual(deck.timer_state(now=1030)["remaining"], 1470)
        with patch.object(deck.time, "time", return_value=2501):
            with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
                claims = list(pool.map(lambda _: deck.claim_completion(), range(2)))
        self.assertEqual(sorted(claims), [False, True])
        self.assertEqual(deck.timer_state(now=2501)["state"], "done")
        deck.update_timer({"action": "reset"})
        self.assertEqual(deck.timer_state()["state"], "idle")

    def test_running_session_is_not_silently_replaced(self):
        deck.update_timer({"action": "start", "minutes": 25})
        with self.assertRaises(ValueError):
            deck.update_timer({"action": "start", "minutes": 50})
        self.assertEqual(deck.timer_state()["minutes"], 25)
        deck.update_timer({"action": "reset"})
        with self.assertRaises(ValueError):
            deck.update_timer({"action": "start", "minutes": "25"})

    def test_malformed_state_and_oversized_labels(self):
        state = deck.STATE / "session.json"
        for data in ([], {"minutes": 25, "start": "x", "end": 99},
                     {"minutes": 25, "start": 0, "end": float("inf")}):
            state.write_text(json.dumps(data))
            self.assertEqual(deck.timer_state()["state"], "idle")
        result = deck.update_timer({"action": "start", "minutes": 5, "label": "x" * 1000})
        self.assertEqual(len(result["timer"]["label"]), 100)

    def test_markup_stays_literal_and_never_enters_notifications(self):
        markup = '<img src="https://example.invalid/tracker"> & <b>task</b>'
        deck.update_timer({"action": "start", "minutes": 5, "label": markup})
        self.assertIn(markup, deck.badge(deck.timer_state())["tooltip"])
        config = (ROOT / ".config/waybar/common.jsonc").read_text()
        start = config.index('"custom/flightdeck": {')
        end = config.index('\n  },', start)
        self.assertIn('"escape": true', config[start:end])
        plugin = ROOT.parent / "omarchy/.config/omarchy/plugins/aphexlog.flightdeck"
        self.assertIn("textFormat: Text.PlainText", (plugin / "PlainText.qml").read_text())
        with patch.object(deck, "claim_completion", return_value=True), patch.object(deck.subprocess, "run") as notify:
            deck.notify_completion()
        self.assertNotIn(markup, " ".join(notify.call_args.args[0]))


if __name__ == "__main__":
    unittest.main()
