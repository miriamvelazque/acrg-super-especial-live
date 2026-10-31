-- Rally Fueguino A.PI.TU.R. - 10: TRAZABILIDAD completa de los tiempos
-- Ejecutar UNA vez en Supabase > SQL Editor (despues de 01 y 02). No borra ni modifica datos existentes.
-- Agrega:
--   1) time_entries.validated_by / validated_at: QUIEN y CUANDO valido cada tiempo.
--   2) time_entries_log: historial inmutable de cada carga, correccion, validacion, reapertura y borrado,
--      con el usuario, la hora y los valores de antes y despues.
--   3) v_historial_tiempos: vista lista para leer (o exportar) el historial.
-- Los registros viejos (anteriores a este script) quedan sin historial: la trazabilidad empieza desde que se ejecuta.

-- 1) Quien valido y cuando -------------------------------------------------------------
alter table public.time_entries
  add column if not exists validated_by uuid references auth.users(id) on delete set null,
  add column if not exists validated_at timestamptz;

create or replace function public.set_validation_meta() returns trigger
language plpgsql as $$
begin
  if new.validated and (tg_op = 'INSERT' or not old.validated) then
    new.validated_by := auth.uid();      -- NULL si se valida desde el SQL Editor
    new.validated_at := now();
  elsif not new.validated then
    new.validated_by := null;            -- al reabrir se limpia (queda en el historial)
    new.validated_at := null;
  end if;
  return new;
end $$;

drop trigger if exists trg_validation_meta on public.time_entries;
create trigger trg_validation_meta before insert or update on public.time_entries
  for each row execute function public.set_validation_meta();

-- 2) Historial inmutable ---------------------------------------------------------------
-- Sin claves foraneas a proposito: el historial sobrevive aunque se borre el tiempo, la tripulacion o el usuario.
create table if not exists public.time_entries_log (
  id               bigint generated always as identity primary key,
  at               timestamptz not null default now(),
  action           text not null check (action in ('insert','update','validate','reopen','delete')),
  entry_id         uuid,
  special_stage_id uuid,
  crew_id          uuid,
  actor            uuid,      -- auth.uid() de quien hizo el cambio (NULL = SQL Editor / sistema)
  actor_name       text,      -- display_name de esa persona en ese momento
  old_data         jsonb,
  new_data         jsonb
);
create index if not exists time_entries_log_entry on public.time_entries_log (entry_id, at);
create index if not exists time_entries_log_stage on public.time_entries_log (special_stage_id, crew_id);

alter table public.time_entries_log enable row level security;
-- Solo comisario y admin LEEN el historial. No hay politicas de escritura: solo escribe el trigger.
drop policy if exists "comisario y admin leen historial" on public.time_entries_log;
create policy "comisario y admin leen historial" on public.time_entries_log for select to authenticated
  using (public.has_role(array['commissioner','admin']::public.app_role[]));

create or replace function public.log_time_entry() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_action text;
  r        public.time_entries;
  v_name   text;
begin
  if tg_op = 'DELETE' then
    r := old; v_action := 'delete';
  elsif tg_op = 'INSERT' then
    r := new; v_action := 'insert';
  else
    r := new;
    v_action := case when not old.validated and new.validated then 'validate'
                     when old.validated and not new.validated then 'reopen'
                     else 'update' end;
    -- Un "update" que no cambia ningun dato de tiempo no se registra.
    if v_action = 'update' and (old.status, old.start_cs, old.finish_cs, old.penalty_cs)
         is not distinct from (new.status, new.start_cs, new.finish_cs, new.penalty_cs) then
      return null;
    end if;
  end if;

  select display_name into v_name from public.staff_roles where user_id = auth.uid();

  insert into public.time_entries_log (action, entry_id, special_stage_id, crew_id, actor, actor_name, old_data, new_data)
  values (v_action, r.id, r.special_stage_id, r.crew_id, auth.uid(), v_name,
          case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) end,
          case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) end);
  return null;
end $$;

drop trigger if exists trg_log_time_entry on public.time_entries;
create trigger trg_log_time_entry after insert or update or delete on public.time_entries
  for each row execute function public.log_time_entry();

-- 3) Vista para leer el historial ------------------------------------------------------
-- Tiempos en centesimas (neto_*_cs). Para verlos en segundos, dividir por 100.
create or replace view public.v_historial_tiempos with (security_invoker = true) as
select l.at                                   as cuando,
       ss.name                                as pe,
       c.car_number                           as auto,
       c.driver                               as piloto,
       case l.action when 'insert'   then 'Carga'
                     when 'update'   then 'Correccion'
                     when 'validate' then 'Validacion'
                     when 'reopen'   then 'Reapertura'
                     when 'delete'   then 'Borrado' end as accion,
       coalesce(l.actor_name, 'SQL Editor / sistema') as quien,
       (l.old_data->>'net_cs')::int           as neto_antes_cs,
       (l.new_data->>'net_cs')::int           as neto_despues_cs,
       (l.old_data->>'penalty_cs')::int       as penal_antes_cs,
       (l.new_data->>'penalty_cs')::int       as penal_despues_cs,
       l.old_data->>'status'                  as estado_antes,
       l.new_data->>'status'                  as estado_despues
from public.time_entries_log l
left join public.special_stages ss on ss.id = l.special_stage_id
left join public.crews c           on c.id  = l.crew_id;

grant select on public.v_historial_tiempos to authenticated;

-- Uso:
--   select * from public.v_historial_tiempos order by cuando desc limit 100;
--   select * from public.v_historial_tiempos where auto = 733 order by cuando;
-- Despues del ensayo, antes de la carrera real, limpiar el historial de prueba:
--   truncate public.time_entries_log;
