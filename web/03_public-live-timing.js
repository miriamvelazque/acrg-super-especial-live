// Cliente del Dashboard Publico: carga inicial + suscripcion Realtime a "results".
// Usar como <script type="module">. La anon key es publica por diseno; nunca pongas la service_role.
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

const SUPABASE_URL = 'https://trlafoxlpxotbevcgash.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_cTEJf_B0j3I8Dqq3UI4T1A_HDsWIa6n';
export const sb = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export const state = { crews: new Map(), stages: [], results: new Map(), last: 0 };
// Hora (zona Tierra del Fuego) en formato HH:MM:SS a partir de milisegundos. Sin dato = --:--:--
export const clock = ms => ms ? new Date(ms).toLocaleTimeString('es-AR', { hourCycle: 'h23', timeZone: 'America/Argentina/Ushuaia' }) : '--:--:--';
const key = r => `${r.special_stage_id}:${r.crew_id}`;

export async function loadSnapshot(eventId) {
  const [c, s, r] = await Promise.all([
    sb.from('crews').select('*').eq('event_id', eventId).order('car_number'),
    sb.from('special_stages').select('id, number, name, distance_km, stage_id, stages(number)')
      .eq('event_id', eventId).order('number'),
    sb.from('results').select('*').eq('event_id', eventId),
  ]);
  for (const x of [c, s, r]) if (x.error) throw x.error;
  state.crews = new Map(c.data.map(x => [x.id, x]));
  state.stages = s.data;
  state.results = new Map(r.data.map(x => [key(x), x]));
  // Ultima actualizacion = momento en que se valido/cargo el dato mas reciente (no el reloj del equipo).
  state.last = Math.max(state.last, ...r.data.map(x => Date.parse(x.updated_at) || 0));
}

// onUpdate(state) se llama en cada cambio. Devuelve una funcion para cerrar la suscripcion.
export function startLive(eventId, onUpdate) {
  let poll;
  const notify = () => onUpdate(state);
  const refresh = () => loadSnapshot(eventId).then(notify).catch(console.error);

  const channel = sb.channel(`live-${eventId}`);
  for (const ev of ['INSERT', 'UPDATE']) {
    channel.on('postgres_changes',
      { event: ev, schema: 'public', table: 'results', filter: `event_id=eq.${eventId}` },
      p => { state.results.set(key(p.new), p.new); state.last = Math.max(state.last, Date.parse(p.new.updated_at) || Date.now()); notify(); });
  }
  // Los DELETE no admiten filtro. Con RLS activa, p.old trae solo la clave primaria (special_stage_id y crew_id),
  // sin event_id: se borra por esa clave (si la fila es de otro evento, simplemente no esta en el mapa).
  channel.on('postgres_changes', { event: 'DELETE', schema: 'public', table: 'results' },
    p => { state.results.delete(key(p.old)); state.last = Date.now(); notify(); });   // un tiempo reabierto tambien es un cambio

  channel.subscribe(status => {
    if (status === 'SUBSCRIBED') { clearInterval(poll); refresh(); }   // tambien resincroniza tras reconectar
    else if (['CHANNEL_ERROR', 'TIMED_OUT', 'CLOSED'].includes(status)) {
      clearInterval(poll); poll = setInterval(refresh, 10000);        // respaldo por polling
    }
  });
  return () => { clearInterval(poll); sb.removeChannel(channel); };
}

// Adapta el estado al formato de la tabla del dashboard:
// t[i] = centesimas | 'DNF' | undefined (todavia sin tiempo), pen[i] = centesimas de penalizacion.
export function toRows(st) {
  return [...st.crews.values()].map(c => {
    const rs = st.stages.map(pe => st.results.get(`${pe.id}:${c.id}`));
    return { n: c.car_number, cat: c.category, p: c.driver, nv: c.co_driver, pe: c.team,
      t: rs.map(r => !r ? undefined : r.status === 'dnf' ? 'DNF' : r.net_cs),
      pen: rs.map(r => r?.penalty_cs ?? 0) };
  });
}

// Ejemplo: startLive('UUID-DEL-EVENTO', st => renderTabla(toRows(st)));

export async function liveEvent() {
  const { data, error } = await sb.from('events').select('*').eq('is_live', true).maybeSingle();
  if (error) throw error;
  return data;
}
