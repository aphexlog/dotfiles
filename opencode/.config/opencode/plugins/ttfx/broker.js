import { randomUUID } from "node:crypto";
import { validateSpec } from "./spec.js";

// In-memory, location-scoped bridge. Never persist text or mistake emission for
// successful display. Exactly one visible TUI may claim each request.
export function createBroker({ emit, schedule = setTimeout, cancel = clearTimeout, uuid = randomUUID }) {
  const jobs = new Map();
  function cancelClient(job) {
    return Promise.resolve(emit("cancel", { requestID: job.requestID, sessionID: job.sessionID })).catch(() => {});
  }
  function settle(job, status, message) {
    if (!jobs.delete(job.requestID)) return;
    cancel(job.timer);
    job.signal?.removeEventListener("abort", job.abort);
    job.resolve({ status, requestID: job.requestID, effect: job.spec.effect, framesReceived: job.started, ...(message ? { message } : {}) });
  }
  function stop(sessionID) {
    let count = 0;
    for (const job of [...jobs.values()]) {
      if (sessionID !== undefined && job.sessionID !== sessionID) continue;
      count++;
      void cancelClient(job);
      settle(job, "stopped", "Playback cancelled");
    }
    return count;
  }
  return {
    async play(sessionID, input, signal) {
      const spec = validateSpec(input);
      if (signal?.aborted) return { status: "stopped", framesReceived: false };
      if (jobs.size >= 16 || [...jobs.values()].some((job) => job.sessionID === sessionID)) {
        return { status: "busy", framesReceived: false, message: "A ttfx request is already pending" };
      }
      let resolve;
      const result = new Promise((done) => { resolve = done; });
      const job = { requestID: uuid(), sessionID, spec, signal, resolve, started: false };
      job.abort = () => { void cancelClient(job); settle(job, "stopped", "Tool execution cancelled"); };
      jobs.set(job.requestID, job);
      job.timer = schedule(() => {
        void cancelClient(job);
        settle(job, "not_displayed", "No visible compatible OpenCode TUI claimed playback within 5 seconds");
      }, 5000);
      signal?.addEventListener("abort", job.abort, { once: true });
      try {
        await emit("play", { requestID: job.requestID, sessionID, ...spec });
      } catch (error) { settle(job, "failed", String(error.message ?? error).slice(0, 1000)); }
      return result;
    },
    claim({ requestID, sessionID, clientID }) {
      const job = jobs.get(requestID);
      if (!job || job.clientID || job.sessionID !== sessionID) return { accepted: false };
      job.clientID = clientID;
      cancel(job.timer);
      job.timer = schedule(() => {
        void cancelClient(job);
        settle(job, "failed", "TUI playback acknowledgement exceeded 35 seconds");
      }, 35000);
      return { accepted: true };
    },
    report({ requestID, clientID, status, message }) {
      const job = jobs.get(requestID);
      if (!job || !job.clientID || job.clientID !== clientID) return { accepted: false };
      if (status === "started") job.started = true;
      else if (["completed", "stopped", "failed"].includes(status)) {
        settle(job, status === "completed" && !job.started ? "not_displayed" : status, message);
      } else return { accepted: false };
      return { accepted: true };
    },
    stop,
    dispose() { stop(); },
  };
}
