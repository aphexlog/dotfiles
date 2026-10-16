#!/usr/bin/env python3
"""Download the pinned model shards resumably and verify their SHA-256 hashes."""

import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess
import urllib.parse


# This script may be Stow-linked; downloads belong in live data, not the repo.
ROOT = Path.home() / ".local/share/local-llm"
MANIFEST = json.loads((ROOT / "manifest.json").read_text())


def download(entry):
    destination = ROOT / "models" / entry["path"]
    destination.parent.mkdir(parents=True, exist_ok=True)
    partial = destination.with_suffix(destination.suffix + ".partial")
    if not destination.exists():
        url = (
            "https://huggingface.co/"
            + MANIFEST["repository"]
            + "/resolve/"
            + MANIFEST["revision"]
            + "/"
            + urllib.parse.quote(entry["path"], safe="/")
            + "?download=true"
        )
        print(f"Downloading {entry['path']} ({entry['size'] / 1e9:.2f} GB)", flush=True)
        subprocess.run(
            [
                "curl", "--fail", "--location", "--silent", "--show-error",
                "--retry", "8", "--retry-delay", "3", "--connect-timeout", "30",
                "--continue-at", "-", "--output", str(partial), url,
            ],
            check=True,
        )
        candidate = partial
    else:
        candidate = destination
    if candidate.stat().st_size != entry["size"]:
        raise RuntimeError(f"Unexpected size for {candidate}")
    print(f"Verifying {entry['path']}", flush=True)
    with candidate.open("rb") as stream:
        actual = hashlib.file_digest(stream, "sha256").hexdigest()
    if actual != entry["sha256"]:
        raise RuntimeError(f"Checksum mismatch for {candidate}: {actual}")
    if candidate == partial:
        partial.rename(destination)
    print(f"Verified {destination}", flush=True)


if __name__ == "__main__":
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        list(pool.map(download, MANIFEST["files"]))
    print("All model files downloaded and verified.", flush=True)
