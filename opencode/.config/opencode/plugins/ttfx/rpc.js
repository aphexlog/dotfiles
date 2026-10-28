import { Rpc } from "@opencode/plugin/rpc";
import { PLAY_SCHEMA } from "./spec.js";

const identifier = { type: "string", minLength: 1, maxLength: 256 };
const accepted = { type: "object", properties: { accepted: { type: "boolean" } }, required: ["accepted"], additionalProperties: false };

export const Ttfx = Rpc.define({
  id: "ttfx",
  methods: {
    claim: {
      input: {
        type: "object", properties: { requestID: identifier, sessionID: identifier, clientID: identifier },
        required: ["requestID", "sessionID", "clientID"], additionalProperties: false,
      }, output: accepted,
    },
    report: {
      input: {
        type: "object",
        properties: {
          requestID: identifier, clientID: identifier,
          status: { type: "string", enum: ["started", "completed", "stopped", "failed"] },
          message: { type: "string", maxLength: 1000 },
        }, required: ["requestID", "clientID", "status"], additionalProperties: false,
      }, output: accepted,
    },
  },
  events: {
    play: {
      schema: {
        ...PLAY_SCHEMA,
        properties: { ...PLAY_SCHEMA.properties, requestID: identifier, sessionID: identifier },
        required: ["text", "effect", "theme", "requestID", "sessionID"],
      },
    },
    cancel: {
      schema: {
        type: "object", properties: { requestID: identifier, sessionID: identifier },
        required: ["requestID", "sessionID"], additionalProperties: false,
      },
    },
  },
});
