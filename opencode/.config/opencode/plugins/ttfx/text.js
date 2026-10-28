// Write real RGBA foregrounds through the public native StyledText setter,
// rather than relying on the reconciliation of hundreds of nested JSX spans.
export function paintCanvas(node, canvas, StyledText, RGBA) {
  node.content = new StyledText(canvas.map((span) => ({
    __isChunk: true,
    text: span.text,
    fg: RGBA.fromHex(span.color),
    attributes: 0,
  })));
}
