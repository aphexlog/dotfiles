// Explicitly supported ttfx 0.5 effects; no arbitrary executables or CLI flags.
export const EFFECTS = [
  "beams", "binarypath", "blackhole", "bouncyballs", "bubbles", "burn",
  "colorshift", "crumble", "decrypt", "errorcorrect", "expand", "fireworks",
  "highlight", "laseretch", "matrix", "middleout", "orbittingvolley", "overflow",
  "pour", "print", "rain", "randomsequence", "rings", "scattered", "slice",
  "slide", "smoke", "spotlights", "spray", "swarm", "sweep", "synthgrid",
  "thunderstorm", "unstable", "vhstape", "waves", "wipe",
];

export function validateSpec(input) {
  if (!input || typeof input !== "object" || Array.isArray(input)) throw new Error("Expected ttfx options");
  const { text, effect = "laseretch", theme = "original" } = input;
  if (typeof text !== "string" || !text.trim() || text.length > 4000 || /[\x00-\x09\x0b-\x1f\x7f-\x9f]/u.test(text)) {
    throw new Error("Text must be 1–4000 characters, without tabs, ANSI escapes, or control codes");
  }
  if (!EFFECTS.includes(effect)) throw new Error("Unsupported ttfx effect");
  if (!["original", "cyberpunk"].includes(theme)) throw new Error("Unsupported ttfx theme");
  if (theme === "cyberpunk" && effect !== "laseretch") throw new Error("Cyberpunk colors currently require laseretch");
  const lines = text.split("\n");
  if (lines.length > 24 || lines.some((line) => [...line].length > 120)) {
    throw new Error("Artwork must fit within 120 columns and 24 lines");
  }
  return { text, effect, theme };
}

export const PLAY_SCHEMA = {
  type: "object",
  properties: {
    text: { type: "string", minLength: 1, maxLength: 4000 },
    effect: { type: "string", enum: EFFECTS },
    theme: { type: "string", enum: ["original", "cyberpunk"] },
  },
  required: ["text"], additionalProperties: false,
};
