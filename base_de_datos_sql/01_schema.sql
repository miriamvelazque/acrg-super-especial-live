-- SÚPER ESPECIAL ACRG - Live Timing 
-- 01: esquema. Todos los tiempos se guardan en CENTESIMAS (integer).
-- Horas de largada/llegada: centesimas desde medianoche (0 a 8.639.999).

create type public.entry_status as enum ('ok', 'dnf');
create type public.app_role as enum ('timekeeper', 'commissioner', 'admin');

create table public.events (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  venue      text,
  starts_on  date not null,
  ends_on    date,
  is_live    boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.stages (            -- Etapa 1 (sabado), Etapa 2 (domingo)
  id         uuid primary key default gen_random_uuid(),
  event_id   uuid not null references public.events(id) on delete cascade,
  number     smallint not null check (number > 0),
  name       text,
  stage_date date,
  unique (event_id, number)
);

create table public.special_stages (    -- PE1, PE2... (numeracion corrida por evento)
  id          uuid primary key default gen_random_uuid(),
  event_id    uuid not null references public.events(id) on delete cascade,
  stage_id    uuid not null references public.stages(id) on delete cascade,
  number      smallint not null check (number > 0),
  name        text not null,
  distance_km numeric(6,2),
  status      text not null default 'pending' check (status in ('pending','running','finished')),
  unique (event_id, number)
);

create table public.crews (
  id         uuid primary key default gen_random_uuid(),
  event_id   uuid not null references public.events(id) on delete cascade,
  car_number integer not null,
  driver     text not null,
  co_driver  text,
  category   text not null,             -- C1, D, F, RC-E, CT...
  car_model  text,
  team       text,                      -- pena / equipo
  unique (event_id, car_number)
);

-- PRIVADA: solo cronometristas. Guarda las horas crudas y el calculo.
create table public.time_entries (
  id               uuid primary key default gen_random_uuid(),
  special_stage_id uuid not null references public.special_stages(id) on delete cascade,
  crew_id          uuid not null references public.crews(id) on delete cascade,
  status           public.entry_status not null default 'ok',
  start_cs         integer check (start_cs between 0 and 8639999),
  finish_cs        integer check (finish_cs between 0 and 8639999),
  penalty_cs       integer not null default 0 check (penalty_cs >= 0),
  -- Tiempo de PE = llegada - largada + penalizacion. NULL si no hay tiempos (DNF).
  net_cs           integer generated always as (
                     case when start_cs is not null and finish_cs is not null
                          then finish_cs - start_cs + penalty_cs end) stored,
  validated        boolean not null default false,   -- lo valida el comisario
  entered_by       uuid default auth.uid() references auth.users(id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (special_stage_id, crew_id),
  constraint ok_needs_valid_times check
    (status <> 'ok' or (start_cs is not null and finish_cs is not null and finish_cs > start_cs)),
  constraint dnf_has_no_time check
    (status = 'ok' or (start_cs is null and finish_cs is null))
);
create index on public.time_entries (special_stage_id);

-- PUBLICA: lo unico que ve el publico (tiempo neto, penalizacion, estado).
-- Se llena SOLO por trigger cuando el comisario valida. Nunca expone horas de largada/llegada.
create table public.results (
  event_id         uuid not null references public.events(id) on delete cascade,
  special_stage_id uuid not null references public.special_stages(id) on delete cascade,
  crew_id          uuid not null references public.crews(id) on delete cascade,
  status           public.entry_status not null,
  net_cs           integer,
  penalty_cs       integer not null default 0,
  updated_at       timestamptz not null default now(),
  primary key (special_stage_id, crew_id)
);
create index on public.results (event_id);

create table public.staff_roles (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  role         public.app_role not null,
  display_name text
);

-- Triggers ---------------------------------------------------------------
create function public.touch_updated_at() returns trigger
language plpgsql as $$ begin new.updated_at = now(); return new; end $$;

create trigger trg_touch before update on public.time_entries
  for each row execute function public.touch_updated_at();

create function public.sync_result() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_event uuid;
begin
  if tg_op = 'DELETE' then
    delete from results where special_stage_id = old.special_stage_id and crew_id = old.crew_id;
    return old;
  end if;
  if new.validated then
    select event_id into v_event from special_stages where id = new.special_stage_id;
    insert into results (event_id, special_stage_id, crew_id, status, net_cs, penalty_cs)
    values (v_event, new.special_stage_id, new.crew_id, new.status, new.net_cs, new.penalty_cs)
    on conflict (special_stage_id, crew_id) do update
      set status = excluded.status, net_cs = excluded.net_cs,
          penalty_cs = excluded.penalty_cs, updated_at = now();
  else  -- si el comisario reabre el tiempo, desaparece de la web publica
    delete from results where special_stage_id = new.special_stage_id and crew_id = new.crew_id;
  end if;
  return new;
end $$;

create trigger trg_sync_result after insert or update or delete on public.time_entries
  for each row execute function public.sync_result();

-- (Sin datos iniciales: el evento y las PE se crean con 11_evento_super_especial_acrg.sql)
