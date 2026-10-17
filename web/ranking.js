// Clasificacion en vivo. t[i] = centesimas | 'DNF' | undefined (PE todavia no corrida).
// t ya incluye la penalizacion (net_cs de la base): NO se vuelve a sumar.
export const isN = v => typeof v === 'number';

export function rank(rows, a, b) {
  const x = rows.map(c => {
    const ts = c.t.slice(a, b), dnf = ts.includes('DNF'), nums = ts.filter(isN);
    return { c, dnf, done: nums.length, span: b - a, tot: nums.length && !dnf ? nums.reduce((s, v) => s + v, 0) : null };
  });
  // Mas PE completadas primero; dentro de cada grupo, menor acumulado.
  const act = x.filter(r => !r.dnf && r.done).sort((p, q) => q.done - p.done || p.tot - q.tot);
  const K = act.length ? act[0].done : 0;
  let lead = null;
  act.forEach((r, i) => {
    r.pos = i + 1; r.K = K; r.part = r.done < K;               // part = le faltan PE respecto al grupo lider
    if (!r.part) { lead ??= r.tot; r.gap = r.tot - lead } else r.gap = null; // solo es comparable con igual cantidad de PE
  });
  const none = x.filter(r => !r.dnf && !r.done).map(r => Object.assign(r, { pos: '-', gap: null, K }));
  const out = x.filter(r => r.dnf).map(r => Object.assign(r, { pos: 'DNF', gap: null, K }));
  return act.concat(none, out);
}
