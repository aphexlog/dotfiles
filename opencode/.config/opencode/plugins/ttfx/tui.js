import { Plugin } from "@opencode/plugin/tui";
import { jsx } from "@opentui/solid/jsx-runtime";
import { useTerminalDimensions } from "@opentui/solid";
import { RGBA, StyledText } from "@opentui/core";
import { createEffect, createMemo, createSignal, on, Show } from "solid-js";
import { randomUUID } from "node:crypto";
import { Ttfx } from "./rpc.js";
import { EFFECTS, validateSpec } from "./spec.js";
import { createPlayback } from "./player.js";
import { callBridge } from "./bridge.js";
import { paintCanvas } from "./text.js";

export default Plugin.define({
  id: "dotfiles.ttfx.tui",
  setup(context) {
    if (context.options.enabled === false) return;
    const rpc = context.client.rpc(Ttfx);
    const clientID = randomUUID();
    const [target, setTarget] = createSignal(undefined);
    const [canvas, setCanvas] = createSignal([]);
    let job;
    const routeKey = createMemo(() => {
      const route = context.ui.router.current();
      return route.type === "session" ? route.sessionID : route.type;
    });
    const report = (run, status, message) => {
      if (!run.remote) return;
      run.reporting = run.reporting.then(() => callBridge(context.client, "report", { requestID: run.requestID, clientID, status, ...(message ? { message: message.slice(0, 1000) } : {}) }, run.location)).catch((error) => {
        context.ui.toast.show({ title: "ttfx acknowledgement", message: String(error.message ?? error), variant: "warning" });
      });
    };
    const finish = (reason, message) => {
      const run = job;
      job = undefined;
      setTarget(undefined);
      if (run) report(run, reason, message);
    };
    const player = createPlayback({
      onFrame: (frame) => {
        if (!job) return;
        setCanvas(frame);
        if (!job.started && frame.some((span) => span.text.trim())) {
          job.started = true;
          report(job, "started");
        }
      },
      onHide: (reason) => { if (reason !== "failed") finish(reason); },
      onError: (error) => {
        finish("failed", error.message);
        context.ui.toast.show({ title: "ttfx", message: error.message, variant: "warning", duration: 6000 });
      },
    });
    function play(input, remote = false, location) {
      const spec = validateSpec(input);
      player.stop();
      const width = Math.max(8, Math.min(120, context.renderer.width - 36));
      const height = Math.max(4, Math.min(24, context.renderer.height - 8));
      job = { requestID: input.requestID, sessionID: input.sessionID ?? routeKey(), remote, location, started: false, reporting: Promise.resolve() };
      setTarget(job.sessionID);
      setCanvas([]);
      player.start({ ...spec, width, height, reducedMotion: context.options.reducedMotion === true });
    }
    const unsubscribePlay = rpc.events.on("play", (event) => {
      const request = event.data;
      if (job || routeKey() !== request.sessionID) return;
      const location = { directory: (event.location ?? context.location ?? context.data.location.default()).directory };
      void (async () => {
        const claimed = await callBridge(context.client, "claim", { requestID: request.requestID, sessionID: request.sessionID, clientID }, location);
        if (!claimed.accepted) return;
        if (job || routeKey() !== request.sessionID) {
          await callBridge(context.client, "report", { requestID: request.requestID, clientID, status: "stopped", message: "TUI is no longer displaying this session" }, location);
          return;
        }
        try { play(request, true, location); }
        catch (error) { await callBridge(context.client, "report", { requestID: request.requestID, clientID, status: "failed", message: String(error.message).slice(0, 1000) }, location); }
      })().catch((error) => {
        context.ui.toast.show({ title: "ttfx bridge", message: String(error.message ?? error), variant: "warning" });
      });
    });
    const unsubscribeCancel = rpc.events.on("cancel", (event) => {
      if (job?.remote && job.requestID === event.data.requestID) player.stop();
    });
    createEffect(on(routeKey, (key) => { if (job && key !== job.sessionID) player.stop(); }));

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "ttfx.play", title: "Play ttfx text effect", group: "ttfx", palette: true,
          slash: { name: "ttfx", arguments: true },
          run: async (input) => {
            const text = input?.trim() || await context.ui.dialog.prompt({ title: "ttfx text", placeholder: "Text or artwork to animate" });
            if (!text) return;
            const effect = await context.ui.dialog.select({ title: "ttfx effect", current: "laseretch", options: EFFECTS.map((name) => ({ title: name, value: name })) });
            if (!effect) return;
            try { play({ text, effect, theme: effect === "laseretch" ? "cyberpunk" : "original" }); }
            catch (error) { context.ui.toast.show({ title: "ttfx", message: error.message, variant: "error" }); }
          },
        },
        { id: "ttfx.stop", title: "Stop ttfx animation", group: "ttfx", palette: true, slash: { name: "ttfx-stop" }, run: () => player.stop() },
      ],
    }));

    function Canvas(props) {
      const dimensions = useTerminalDimensions();
      createEffect(on(dimensions, () => player.stop(), { defer: true }));
      return jsx(Show, {
        get when() { return target() !== undefined && target() === (props.sessionID ?? "home"); },
        get children() {
          return jsx("box", {
            width: "100%", alignItems: "center", flexDirection: "column", paddingTop: 1, paddingBottom: 1,
            children: jsx("text", {
              wrapMode: "none",
              ref: (node) => createEffect(() => paintCanvas(node, canvas(), StyledText, RGBA)),
            }),
          });
        },
      });
    }
    const removeSession = context.ui.slot({ append: "session.composer.top", render: (props) => jsx(Canvas, props) });
    const removeHome = context.ui.slot({ append: "home.footer", render: () => jsx(Canvas, {}) });
    return () => {
      unsubscribePlay(); unsubscribeCancel(); player.stop(); removeSession(); removeHome();
    };
  },
});
