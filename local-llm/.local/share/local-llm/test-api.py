#!/usr/bin/env python3
"""Check the local API's tool-call round trip, streaming, and generation timings."""

import json
from pathlib import Path
import secrets
import time
import urllib.request


# This script may be Stow-linked; generated results stay outside the repo.
ROOT = Path.home() / ".local/share/local-llm"
BASE = "http://127.0.0.1:8080"
MODEL = "qwen3.8-flash-next-abliterated"


def post(payload):
    request = urllib.request.Request(
        BASE + "/v1/chat/completions",
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
    )
    started = time.monotonic()
    with urllib.request.urlopen(request, timeout=1800) as response:
        result = json.load(response)
    return result, time.monotonic() - started


if __name__ == "__main__":
    marker = "verified-" + secrets.token_hex(8)
    messages = [
        {"role": "system", "content": "Use the provided tool to retrieve facts. Never invent a tool result."},
        {"role": "user", "content": "Call get_project_value with key build_id, then report its exact returned value."},
    ]
    tools = [{
        "type": "function",
        "function": {
            "name": "get_project_value",
            "description": "Read a value from the current project.",
            "parameters": {
                "type": "object",
                "properties": {"key": {"type": "string"}},
                "required": ["key"],
                "additionalProperties": False,
            },
        },
    }]
    common = {
        "model": MODEL,
        "temperature": 0,
        "max_tokens": 256,
        "chat_template_kwargs": {"enable_thinking": False},
    }
    first, first_seconds = post({**common, "messages": messages, "tools": tools})
    assistant = first["choices"][0]["message"]
    calls = assistant.get("tool_calls", [])
    assert len(calls) == 1, first
    call = calls[0]
    assert call["function"]["name"] == "get_project_value", first
    assert json.loads(call["function"]["arguments"]) == {"key": "build_id"}, first
    messages.extend([
        assistant,
        {"role": "tool", "tool_call_id": call["id"], "content": json.dumps({"value": marker})},
    ])
    second, second_seconds = post({**common, "messages": messages, "tools": tools})
    assert marker in second["choices"][0]["message"].get("content", ""), second

    stream_request = urllib.request.Request(
        BASE + "/v1/chat/completions",
        data=json.dumps({
            **common,
            "messages": [{"role": "user", "content": "Reply with exactly LOCAL_STREAM_OK"}],
            "stream": True,
        }).encode(),
        headers={"Content-Type": "application/json"},
    )
    chunks = []
    done = False
    with urllib.request.urlopen(stream_request, timeout=1800) as response:
        for raw in response:
            line = raw.decode().strip()
            if not line.startswith("data: "):
                continue
            event = line[6:]
            if event == "[DONE]":
                done = True
                break
            item = json.loads(event)
            for choice in item.get("choices", []):
                chunks.append(choice.get("delta", {}).get("content", "") or "")
    text = "".join(chunks)
    assert done and "LOCAL_STREAM_OK" in text, text
    result = {
        "model": MODEL,
        "tool_call": "passed",
        "tool_result_round_trip": "passed",
        "streaming": "passed",
        "tool_call_seconds": first_seconds,
        "tool_result_seconds": second_seconds,
        "first_timings": first.get("timings"),
        "second_timings": second.get("timings"),
    }
    (ROOT / "api-test-results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
