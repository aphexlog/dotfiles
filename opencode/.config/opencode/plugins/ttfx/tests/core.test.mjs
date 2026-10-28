import assert from "node:assert/strict";
import { test } from "node:test";
import { EventEmitter } from "node:events";
import { createBroker } from "../broker.js";
import { EFFECTS, validateSpec } from "../spec.js";
import { createDecoder, parseCanvas } from "../canvas.js";
import { createPlayback } from "../player.js";
import { createExplosion } from "../outro.js";
import { callBridge, serverHandlers } from "../bridge.js";
import { toolDefinition } from "../tool.js";
import { paintCanvas } from "../text.js";

const MARKER = "\x1b8\x1b7\x1b[4A";
const ART = "\x1b[38;2;0;245;255mTEXT\x1b[0m\n    \n    \n    ";

test("native text preserves the decoded foreground colors without setting a background", () => {
  const node = {};
  class StyledText { constructor(chunks) { this.chunks = chunks; } }
  const RGBA = { fromHex: (hex) => ({ hex }) };
  paintCanvas(node, parseCanvas(ART, 4, 4), StyledText, RGBA);
  assert.equal(node.content.chunks[0].fg.hex, "#00f5ff");
  assert.ok(node.content.chunks.every((chunk) => chunk.__isChunk && !("bg" in chunk)));
});

test("RPC bridge uses the originating location and Promise-returning handlers", async () => {
  const location = { directory: "/games/project" };
  const calls = [];
  const result = await callBridge({ rpc: { call: async (...args) => { calls.push(args); return { output: { accepted: true } }; } } }, "claim", { requestID: "one" }, location);
  assert.equal(result.accepted, true);
  assert.equal(calls[0][0].location, location);
  assert.equal(calls[0][0].rpcID, "ttfx");
  assert.ok(calls[0][1].signal instanceof AbortSignal);
  const handlers = serverHandlers({ claim: () => ({ accepted: false }), report: () => ({ accepted: true }) });
  const reply = handlers.claim({});
  assert.equal(typeof reply.then, "function");
  assert.deepEqual(await reply, { accepted: false });
  assert.deepEqual(await handlers.report({}), { accepted: true });
});

test("native tool checks permission, propagates denial, and never changes rules", async () => {
  const calls = [];
  const ctx = { permission: { assert: async (input) => { calls.push(["permission", input]); } } };
  const broker = { play: async (...args) => { calls.push(["play", args]); return { status: "completed" }; }, stop: () => 0 };
  const tool = toolDefinition(ctx, broker);
  const execution = { sessionID: "one", agent: "build", messageID: "message", id: "call", signal: new AbortController().signal };
  const result = await tool.execute({ action: "play", text: "hello" }, execution);
  assert.equal(JSON.parse(result.content).status, "completed");
  assert.deepEqual(calls.map(([name]) => name), ["permission", "play"]);
  assert.equal(calls[0][1].action, "ttfx");
  assert.deepEqual(calls[0][1].resources, ["laseretch"]);
  assert.equal(calls[1][1][2], execution.signal);
  ctx.permission.assert = async () => { throw new Error("denied"); };
  await assert.rejects(tool.execute({ action: "play", text: "hello" }, execution), /denied/);
  assert.equal(calls.filter(([name]) => name === "play").length, 1);
});

test("validates literal text, allowlisted effects, dimensions, and presets", () => {
  assert.deepEqual(validateSpec({ text: "hello" }), { text: "hello", effect: "laseretch", theme: "original" });
  assert.ok(EFFECTS.includes("laseretch"));
  for (const input of [{ text: "\x1b[2J" }, { text: "a\tb" }, { text: "" }, { text: "x".repeat(121) },
    { text: "x\n".repeat(25) }, { text: "ok", effect: ";sh" }, { text: "ok", theme: "invalid" },
    { text: "ok", effect: "rain", theme: "cyberpunk" }]) assert.throws(() => validateSpec(input));
});

test("decoder preserves RGB/positions while discarding all background/cursor controls", () => {
  const frames = [];
  const decoder = createDecoder(4, 4, (frame) => frames.push(frame));
  for (const ch of "\x1b[?25l" + MARKER + ART + MARKER + ART) decoder.push(ch);
  decoder.finish();
  assert.equal(frames.length, 2);
  assert.equal(frames[0][0].color, "#00f5ff");
  assert.equal(frames[0].map((span) => span.text).join(""), "TEXT\n    \n    \n    ");
  assert.deepEqual(parseCanvas("\x1b[38;2;0;245;255mA\x1b[48;2;0;0;0mB", 4, 4), [{ text: "AB", color: "#00f5ff" }]);
  assert.throws(() => createDecoder(4, 4, () => {}).push("x".repeat(1024 * 1024 + 1)));
});

test("explosion disperses bounded foreground-only particles and ends empty", () => {
  const canvas = [{ text: "    TEST\n    TEST", color: "#ff2bd6" }];
  const burst = createExplosion(canvas, 20, 8);
  assert.equal(burst(0), canvas);
  const middle = burst(0.2);
  assert.match(middle.map((span) => span.text).join(""), /[*·]/u);
  assert.ok(middle.every((span) => Object.keys(span).every((key) => ["text", "color"].includes(key))));
  assert.deepEqual(burst(1), []);
});

function brokerFixture() {
  const events = [], timers = new Map();
  let id = 0;
  const broker = createBroker({
    emit: async (name, data) => { events.push({ name, data }); },
    uuid: () => `request-${++id}`,
    schedule: (callback, delay) => { timers.set(++id, { callback, delay }); return id; },
    cancel: (id) => timers.delete(id),
  });
  return { broker, events, timers, request: () => events.find((event) => event.name === "play").data };
}

test("tool waits for a single client claim and actual frame/completion reports", async () => {
  const state = brokerFixture();
  const result = state.broker.play("session", { text: "test" });
  const { requestID } = state.request();
  assert.equal(state.broker.claim({ requestID, sessionID: "other", clientID: "a" }).accepted, false);
  assert.equal(state.broker.claim({ requestID, sessionID: "session", clientID: "a" }).accepted, true);
  assert.equal(state.broker.claim({ requestID, sessionID: "session", clientID: "b" }).accepted, false);
  assert.equal(state.broker.report({ requestID, clientID: "b", status: "completed" }).accepted, false);
  state.broker.report({ requestID, clientID: "a", status: "started" });
  state.broker.report({ requestID, clientID: "a", status: "completed" });
  assert.equal((await result).status, "completed");
  assert.equal(state.timers.size, 0);
});

test("headless/no-TUI requests report not_displayed rather than success", async () => {
  const state = brokerFixture();
  const result = state.broker.play("session", { text: "test" });
  [...state.timers.values()][0].callback();
  assert.equal((await result).status, "not_displayed");
  assert.ok(state.events.some((event) => event.name === "cancel"));
});

test("completion without a started frame is never reported as displayed", async () => {
  const state = brokerFixture();
  const result = state.broker.play("session", { text: "test" });
  const { requestID } = state.request();
  state.broker.claim({ requestID, sessionID: "session", clientID: "client" });
  state.broker.report({ requestID, clientID: "client", status: "completed" });
  const outcome = await result;
  assert.equal(outcome.status, "not_displayed");
  assert.equal(outcome.framesReceived, false);
});

test("concurrency, cancellation, and unload release pending work", async () => {
  const state = brokerFixture();
  const controller = new AbortController();
  const first = state.broker.play("one", { text: "test" }, controller.signal);
  assert.equal((await state.broker.play("one", { text: "second" })).status, "busy");
  controller.abort();
  assert.equal((await first).status, "stopped");
  const second = state.broker.play("two", { text: "test" });
  state.broker.dispose();
  assert.equal((await second).status, "stopped");
  assert.equal(state.timers.size, 0);
});

function playerFixture() {
  const frames = [], errors = [], ended = [], invocations = [], timers = new Map();
  let id = 0;
  const child = new EventEmitter();
  child.stdout = new EventEmitter(); child.stderr = new EventEmitter(); child.stdin = new EventEmitter();
  child.stdout.setEncoding = child.stderr.setEncoding = () => {};
  child.stdin.end = (text) => { child.input = text; };
  child.signals = []; child.kill = (signal) => child.signals.push(signal);
  const player = createPlayback({
    onFrame: (frame) => frames.push(frame), onHide: (reason) => ended.push(reason), onError: (error) => errors.push(error),
    spawnProcess: (...args) => { invocations.push(args); return child; },
    schedule: (callback, delay) => { timers.set(++id, { callback, delay }); return id; }, cancel: (id) => timers.delete(id),
  });
  return { player, child, frames, errors, ended, invocations, timers, drain() {
    for (let i = 0; i < 30 && timers.size; i++) {
      const [id, timer] = [...timers].sort((a, b) => a[1].delay - b[1].delay)[0];
      timers.delete(id); timer.callback();
    }
  } };
}

test("real process invocation has no shell/files/background flags and ends with particles", () => {
  const state = playerFixture();
  state.player.start({ text: "TEXT", effect: "rain", width: 20, height: 8 });
  const [name, args, options] = state.invocations[0];
  assert.equal(name, "ttfx"); assert.equal(options.shell, false);
  assert.ok(args.includes("rain")); assert.equal(args.some((arg) => /input-file|background/.test(arg)), false);
  assert.equal(state.child.input, "TEXT\n");
  state.child.stdout.emit("data", MARKER + ART); state.child.emit("close", 0);
  state.drain();
  assert.equal(state.frames.length, 21); assert.deepEqual(state.frames.at(-1), []);
  assert.deepEqual(state.ended, ["completed"]); assert.equal(state.errors.length, 0);
});

test("reduced motion skips both process and explosion; cancellation stops owned process", () => {
  const state = playerFixture();
  state.player.start({ text: "TEXT", width: 20, height: 8, reducedMotion: true });
  state.drain(); assert.equal(state.invocations.length, 0); assert.equal(state.frames.length, 1);
  state.player.start({ text: "TEXT", width: 20, height: 8 });
  state.player.stop(); assert.deepEqual(state.child.signals, ["SIGTERM"]);
  state.drain(); assert.deepEqual(state.child.signals, ["SIGTERM", "SIGKILL"]);
  state.child.emit("close", null); assert.equal(state.timers.size, 0);
});

test("missing executable, unsupported output, and clipping fail explicitly", () => {
  const state = playerFixture();
  state.player.start({ text: "x".repeat(30), width: 20, height: 8 });
  assert.equal(state.invocations.length, 0); assert.equal(state.errors.length, 1);
  state.player.start({ text: "TEXT", width: 20, height: 8 });
  state.child.emit("error", new Error("ENOENT"));
  assert.match(state.errors.at(-1).message, /Cannot run installed ttfx/);
});

for (const effect of ["laseretch", "rain", "beams"]) test(`installed ttfx ${effect} decodes and explodes`, {
  skip: !process.env.TTFX_BIN, timeout: 30000,
}, async () => {
  await new Promise((resolve, reject) => {
    const frames = [];
    const player = createPlayback({
      executable: process.env.TTFX_BIN,
      onFrame: (frame) => frames.push(frame), onError: reject,
      onHide: (reason) => {
        if (reason !== "completed") return;
        try {
          assert.ok(frames.length > 20);
          if (effect === "laseretch") {
            const settled = frames.filter((frame) => /TTFX/.test(frame.map((span) => span.text).join(""))).at(-1);
            assert.ok(settled);
            assert.ok(new Set(settled.filter((span) => span.text.trim()).map((span) => span.color)).size >= 3);
          }
          assert.deepEqual(frames.at(-1), []); resolve();
        }
        catch (error) { reject(error); }
      },
    });
    player.start({ text: "TTFX", effect, theme: effect === "laseretch" ? "cyberpunk" : "original", width: 30, height: 10 });
  });
});
