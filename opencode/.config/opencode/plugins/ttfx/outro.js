// Short local finishing animation, separate from the real ttfx entrance effect.
// Break the last rendered glyphs into bounded particles; never paint a backdrop.
export function createExplosion(canvas, width, height) {
  const points = [];
  let x = 0, y = 0;
  for (const span of canvas) for (const character of span.text) {
    if (character === "\n") { y++; x = 0; continue; }
    if (character.trim() && x < width && y < height) points.push({ x, y, color: span.color });
    x++;
  }
  const cx = points.reduce((sum, point) => sum + point.x, 0) / Math.max(1, points.length);
  const cy = points.reduce((sum, point) => sum + point.y, 0) / Math.max(1, points.length);
  const stride = Math.max(1, Math.ceil(points.length / 600));
  const particles = points.filter((_, index) => index % stride === 0).map((point, index) => {
    const noise = ((index * 73 + point.x * 19 + point.y * 37) % 101) / 100;
    return {
      ...point, life: 0.35 + noise * 0.55,
      vx: (point.x - cx) * 1.3 + (noise - 0.5) * 12,
      vy: (point.y - cy) * 2 + ((index * 13 % 23) / 22 - 0.7) * 9,
    };
  });
  return (progress) => {
    if (progress <= 0) return canvas;
    if (progress >= 1) return [];
    const grid = Array.from({ length: height }, () => Array(width));
    for (const particle of particles) {
      if (progress >= particle.life) continue;
      const px = Math.round(particle.x + particle.vx * progress);
      const py = Math.round(particle.y + particle.vy * progress + 6 * progress * progress);
      if (px < 0 || px >= width || py < 0 || py >= height) continue;
      grid[py][px] = { text: progress < particle.life * 0.55 ? "*" : "·", color: particle.color };
    }
    const spans = [];
    const append = (text, color = "#ffffff") => {
      if (spans.at(-1)?.color === color) spans.at(-1).text += text;
      else spans.push({ text, color });
    };
    grid.forEach((row, index) => {
      for (let column = 0; column < width; column++) {
        const cell = row[column];
        append(cell?.text ?? " ", cell?.color);
      }
      if (index < height - 1) append("\n");
    });
    return spans;
  };
}
