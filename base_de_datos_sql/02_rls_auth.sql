-- 02: seguridad (RLS), roles y Realtime.
-- Roles: timekeeper (carga), commissioner (valida/reabre), admin (todo).

alter table public.events         enable row level security;
alter table public.stages         enable row level security;
alter table public.special_stages enable row level security;
alter table public.crews          enable row level security;
alter table public.results        enable row level security;
alter table public.time_entries   enable row level security;
alter table public.staff_roles    enable row level security;

create function public.has_role(allowed public.app_role[]) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from staff_roles where user_id = (select auth.uid()) and role = any(allowed));
$$;
revoke execute on function public.has_role(public.app_role[]) from public, anon;
grant  execute on function public.has_role(public.app_role[]) to authenticated;

-- Catalogo (eventos, etapas, PE, tripulaciones): lectura libre, escritura solo admin.
do $$ declare t text; begin
  foreach t in array array['events','stages','special_stages','crews'] loop
    execute format('create policy "lectura publica" on public.%I for select to anon, authenticated using (true)', t);
    execute format('create policy "admin escribe" on public.%I for all to authenticated
      using (public.has_role(array[''admin'']::public.app_role[]))
      with check (public.has_role(array[''admin'']::public.app_role[]))', t);
  end loop;
end $$;

-- Resultados publicos: lectura libre. Sin politicas de escritura: solo escribe el trigger.
create policy "lectura publica" on public.results for select to anon, authenticated using (true);

-- Tiempos crudos: privados, solo personal con sesion.
create policy "personal lee" on public.time_entries for select to authenticated
  using (public.has_role(array['timekeeper','commissioner','admin']::public.app_role[]));

create policy "cronometrista carga" on public.time_entries for insert to authenticated
  with check (public.has_role(array['timekeeper','commissioner','admin']::public.app_role[])
              and validated = false and entered_by = (select auth.uid()));

create policy "cronometrista corrige si no esta validado" on public.time_entries for update to authenticated
  using (public.has_role(array['timekeeper','commissioner','admin']::public.app_role[]) and not validated)
  with check (validated = false);

create policy "comisario valida y reabre" on public.time_entries for update to authenticated
  using (public.has_role(array['commissioner','admin']::public.app_role[])) with check (true);

create policy "admin borra" on public.time_entries for delete to authenticated
  using (public.has_role(array['admin']::public.app_role[]));

-- Roles del personal
create policy "ver mi rol" on public.staff_roles for select to authenticated
  using (user_id = (select auth.uid()) or public.has_role(array['admin']::public.app_role[]));
create policy "admin gestiona roles" on public.staff_roles for all to authenticated
  using (public.has_role(array['admin']::public.app_role[]))
  with check (public.has_role(array['admin']::public.app_role[]));

-- Realtime: la web publica escucha "results"; los cronometristas escuchan "time_entries".
-- REPLICA IDENTITY FULL para que los DELETE traigan la fila completa.
alter table public.results      replica identity full;
alter table public.time_entries replica identity full;
alter publication supabase_realtime add table public.results, public.time_entries;

-- Primer admin: crea el usuario en Authentication > Users y ejecuta (con su UUID):
-- insert into public.staff_roles (user_id, role, display_name) values ('UUID-DEL-USUARIO', 'admin', 'Nombre');
