// Panel de cronometristas: login, rol, carga, validacion y sincronizacion entre cronometristas.
// Reutiliza el mismo cliente; con sesion activa supabase-js envia el JWT y RLS deja pasar las escrituras.
import { sb } from './03_public-live-timing.js';

export async function signIn(email, password) {
  const { data, error } = await sb.auth.signInWithPassword({ email, password });
  if (error) throw new Error('Email o contraseña incorrectos.');
  return data.session;
}
export const signOut = () => sb.auth.signOut();
export const onAuth = cb => sb.auth.onAuthStateChange((_ev, session) => cb(session));

// { role: 'timekeeper' | 'commissioner' | 'admin', display_name } o null si no es personal autorizado.
export async function myRole() {
  const { data: { user } } = await sb.auth.getUser();
  if (!user) return null;
  const { data } = await sb.from('staff_roles').select('role, display_name').eq('user_id', user.id).maybeSingle();
  return data;
}

// Valores en centesimas (los que ya calculan los parsers del formulario).
// Un DNF no lleva horas: se guarda sin tiempo y nunca suma ni ordena.
export async function saveEntry({ special_stage_id, crew_id, start_cs, finish_cs, penalty_cs = 0, status = 'ok' }) {
  if (!special_stage_id) throw new Error('Esa PE todavía no está creada en la base de datos.');
  const row = { special_stage_id, crew_id, penalty_cs, status,
    start_cs: status === 'ok' ? start_cs : null, finish_cs: status === 'ok' ? finish_cs : null };
  const { data, error } = await sb.from('time_entries')
    .upsert(row, { onConflict: 'special_stage_id,crew_id' }).select().single();
  if (error) {
    if (error.code === '42501') throw new Error('Sin permiso, o el tiempo ya fue validado. Pedile al comisario que lo reabra.');
    throw new Error(error.message);
  }
  return data;
}

// Solo comisario/admin (RLS lo impide al resto). Al validar, el trigger lo publica en "results".
export const validateEntry = (id, validated = true) =>
  sb.from('time_entries').update({ validated }).eq('id', id).select().single();

// Varios cronometristas cargando en paralelo (PE1 y PE2 a la vez): ven los cambios de los demas.
export function watchEntries(onChange) {
  const ch = sb.channel('staff-entries')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'time_entries' }, p => onChange(p))
    .subscribe();
  return () => sb.removeChannel(ch);
}

// Todas las PE del evento, ordenadas por numero. Incluye la etapa a la que pertenecen (stages.number).
export async function loadStages(eventId) {
  const { data, error } = await sb.from('special_stages')
    .select('id, number, name, stage_id, stages(number)')
    .eq('event_id', eventId).order('number', { ascending: true });
  if (error) throw error;
  return data || [];
}
