import { spawn } from "node:child_process";
import { createDecoder, parseCanvas } from "./canvas.js";
import { createExplosion } from "./outro.js";
import { validateSpec } from "./spec.js";

export function effectArgs(spec) {
  if (spec.theme !== "cyberpunk") return [];
  return [
    "--laser-gradient-stops", "ffffff", "00f5ff", "ff2bd6",
    "--cool-gradient-stops", "fff2cc", "ffd166", "ff2bd6",
    "--spark-gradient-stops", "ffffff", "ffd166", "ff2bd6", "662266",
    "--final-gradient-stops", "ff2bd6", "9d4dff", "00f5ff",
    "--final-gradient-direction", "horizontal",
  ];
}

export function createPlayback({ onFrame, onHide, onError, spawnProcess = spawn, schedule = setTimeout, cancel = clearTimeout, executable = "ttfx" }) {
  let current;
  function stop(reason = "stopped") {
    const run = current;
    current = undefined;
    if (!run) return;
    cancel(run.timeout); cancel(run.next);
    if (run.child && !run.closed) {
      run.child.kill("SIGTERM");
      run.kill = schedule(() => { if (!run.closed) run.child.kill("SIGKILL"); }, 500);
      run.kill?.unref?.();
    }
    onHide(reason);
  }
  function start({ text, effect = "laseretch", theme = "original", width, height, reducedMotion = false }) {
    stop();
    let spec;
    try {
      spec = validateSpec({ text, effect, theme });
      if (!Number.isInteger(width) || width < 8 || width > 120 || !Number.isInteger(height) || height < 4 || height > 24) throw new Error("Invalid ttfx canvas dimensions");
      if (text.split("\n").length > height || text.split("\n").some((line) => [...line].length > width)) throw new Error("Artwork does not fit the visible TUI canvas");
    } catch (error) { onError(error); return; }
    const run = { closed: false, final: [] };
    current = run;
    const fail = (error) => { if (current === run) { stop("failed"); onError(error); } };
    const render = (canvas) => { if (current === run) { run.final = canvas; onFrame(canvas); } };
    if (reducedMotion) {
      render(parseCanvas(text, width, height));
      run.next = schedule(() => stop("completed"), 2400);
      return;
    }
    const args = ["--frame-rate", "120", "--canvas-width", String(width), "--canvas-height", String(height),
      "--ignore-terminal-dimensions", "--reuse-canvas", "--anchor-canvas", "c", "--anchor-text", "c",
      "--no-eol", "--no-restore-cursor", effect, ...effectArgs(spec)];
    try { run.child = spawnProcess(executable, args, { stdio: ["pipe", "pipe", "pipe"], shell: false }); }
    catch (error) { fail(error); return; }
    let stderr = "";
    const decoder = createDecoder(width, height, render);
    run.timeout = schedule(() => fail(new Error("ttfx exceeded 30 seconds")), 30000);
    run.child.stdout.setEncoding("utf8"); run.child.stderr.setEncoding("utf8");
    run.child.stdout.on("data", (chunk) => { if (current === run) try { decoder.push(chunk); } catch (error) { fail(error); } });
    run.child.stderr.on("data", (chunk) => { stderr = (stderr + chunk).slice(-500); });
    run.child.stdout.on("error", fail); run.child.stderr.on("error", fail); run.child.stdin.on("error", fail);
    run.child.on("error", (error) => fail(new Error(`Cannot run installed ttfx: ${error.message}`)));
    run.child.on("close", (code) => {
      run.closed = true;
      cancel(run.kill);
      if (current !== run) return;
      cancel(run.timeout);
      if (code !== 0) { fail(new Error(`ttfx exited ${code}: ${stderr.replace(/[\x00-\x1f\x7f]/g, " ")}`)); return; }
      try { decoder.finish(); } catch (error) { fail(error); return; }
      const burst = createExplosion(run.final, width, height);
      let frame = 0;
      const tick = () => {
        if (current !== run) return;
        render(burst(++frame / 20));
        if (frame >= 20) stop("completed");
        else run.next = schedule(tick, 33);
      };
      run.next = schedule(tick, 350);
    });
    run.child.stdin.end(text + "\n");
  }
  return { start, stop };
}
