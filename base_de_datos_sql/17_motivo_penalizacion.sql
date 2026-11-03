-- 17: MOTIVO de la penalización (Adelanto CH / Atraso CH / Chicana / Otro + detalle).
-- Correr UNA vez en Supabase > SQL Editor, DESPUÉS de 01, 02 y 10. Es re-ejecutable. No borra tiempos.
-- Agrega penalty_reason a time_entries (privada) y a results (pública), y hace que el trigger lo publique.

alter table public.time_entries add column if not exists penalty_reason text;
alter table public.results      add column if not exists penalty_reason text;

-- 1) Publicación: igual que en 01_schema.sql, más penalty_reason.
create or replace function public.sync_result() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_event uuid;
begin
  if tg_op = 'DELETE' then
    delete from results where special_stage_id = old.special_stage_id and crew_id = old.crew_id;
    return old;
  end if;
  if new.validated then
    select event_id into v_event from special_stages where id = new.special_stage_id;
    insert into results (event_id, special_stage_id, crew_id, status, net_cs, penalty_cs, penalty_reason)
    values (v_event, new.special_stage_id, new.crew_id, new.status, new.net_cs, new.penalty_cs, new.penalty_reason)
    on conflict (special_stage_id, crew_id) do update
      set status = excluded.status, net_cs = excluded.net_cs, penalty_cs = excluded.penalty_cs,
          penalty_reason = excluded.penalty_reason, updated_at = now();
  else
    delete from results where special_stage_id = new.special_stage_id and crew_id = new.crew_id;
  end if;
  return new;
end $$;

-- 2) Trazabilidad: igual que en 10_trazabilidad.sql, pero un cambio de motivo también queda registrado.
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
    if v_action = 'update' and (old.status, old.start_cs, old.finish_cs, old.penalty_cs, old.penalty_reason)
         is not distinct from (new.status, new.start_cs, new.finish_cs, new.penalty_cs, new.penalty_reason) then
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

-- 3) Vista del historial: mismas columnas de antes + el motivo al final.
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
       l.new_data->>'status'                  as estado_despues,
       l.new_data->>'penalty_reason'          as motivo_despues
from public.time_entries_log l
left join public.special_stages ss on ss.id = l.special_stage_id
left join public.crews c           on c.id  = l.crew_id;

-- 4) Las 4 penalizaciones ya cargadas de la Etapa 1 (celdas "PEOR TIEMPO + 10": 502 en PE1 y 608 en PE1 a PE3).
update public.time_entries te
set penalty_reason = 'Peor tiempo + 10'
from public.special_stages ss join public.events e on e.id = ss.event_id
where te.special_stage_id = ss.id and e.name = 'SÚPER ESPECIAL - ACRG'
  and te.penalty_cs > 0 and te.penalty_reason is null;

-- Verificación: deben salir 4 filas con su motivo, también en la tabla pública.
select c.car_number as auto, ss.name as pe, r.penalty_cs, r.penalty_reason
from public.results r
join public.crews c on c.id = r.crew_id
join public.special_stages ss on ss.id = r.special_stage_id
where r.penalty_cs > 0 order by c.car_number, ss.number;
