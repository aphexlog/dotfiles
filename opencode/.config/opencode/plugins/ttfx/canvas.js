// Decode complete ttfx canvases into foreground-only spans, never terminal I/O.
const MARKER = /\x1b8\x1b7\x1b\[\d+A/;
const ANSI = /(\x1b\[[0-?]*[ -/]*[@-~]|\x1b[78]|\x1b\][^\x07]*(?:\x07|\x1b\\))/g;

export function parseCanvas(payload, width, height) {
  let color = "#ffffff", row = 0, column = 0;
  const spans = [];
  const append = (text) => {
    if (spans.at(-1)?.color === color) spans.at(-1).text += text;
    else spans.push({ text, color });
  };
  for (const token of payload.split(ANSI)) {
    if (!token) continue;
    if (token.startsWith("\x1b")) {
      const match = /^\x1b\[([\d;]*)m$/.exec(token);
      if (!match) continue;
      const codes = (match[1] || "0").split(";").map(Number);
      for (let i = 0; i < codes.length; i++) {
        if ((codes[i] === 38 || codes[i] === 48) && codes[i + 1] === 5) { i += 2; continue; }
        if (codes[i] === 48 && codes[i + 1] === 2) { i += 4; continue; }
        if (codes[i] === 0 || codes[i] === 39) color = "#ffffff";
        if (codes[i] === 38 && codes[i + 1] === 2 && codes.length >= i + 5) {
          const rgb = codes.slice(i + 2, i + 5);
          if (rgb.every((value) => value >= 0 && value <= 255)) color = "#" + rgb.map((value) => value.toString(16).padStart(2, "0")).join("");
          i += 4;
        }
      }
    } else for (const character of token) {
      if (character === "\n") { row++; column = 0; if (row < height) append("\n"); }
      else if (!/[\x00-\x1f\x7f-\x9f]/u.test(character)) {
        if (row < height && column < width) append(character);
        column++;
      }
    }
  }
  return spans;
}

export function createDecoder(width, height, onFrame) {
  let buffer = "", started = false;
  return {
    push(chunk) {
      buffer += chunk;
      if (buffer.length > 1024 * 1024) throw new Error("ttfx canvas exceeded its buffer limit");
      let marker;
      while ((marker = MARKER.exec(buffer))) {
        if (started) onFrame(parseCanvas(buffer.slice(0, marker.index), width, height));
        buffer = buffer.slice(marker.index + marker[0].length);
        started = true;
      }
    },
    finish() {
      if (!started) throw new Error("ttfx returned no supported canvas frames");
      if (buffer) onFrame(parseCanvas(buffer, width, height));
      buffer = "";
    },
  };
}
