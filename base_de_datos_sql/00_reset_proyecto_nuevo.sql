-- 00: RESET del esquema "public" del proyecto de Supabase del ACRG.
-- Borra TODAS las tablas, funciones y tipos enum de "public" (restos de corridas anteriores).
-- No toca los usuarios de Authentication (auth.users).
-- !!! CORRER SOLO EN EL PROYECTO NUEVO DEL ACRG. Antes de ejecutar, mirá el nombre del proyecto
-- !!! arriba a la izquierda en Supabase: si es el de A.PI.TU.R., NO lo corras.
do $$
declare r record;
begin
  for r in select tablename from pg_tables where schemaname = 'public' loop
    execute format('drop table if exists public.%I cascade', r.tablename);
  end loop;

  for r in
    select p.oid::regprocedure::text as sig
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prokind in ('f', 'p')
      and not exists (select 1 from pg_depend d where d.objid = p.oid and d.deptype = 'e')
  loop
    execute format('drop function if exists %s cascade', r.sig);
  end loop;

  for r in
    select t.typname from pg_type t join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typtype = 'e'
  loop
    execute format('drop type if exists public.%I cascade', r.typname);
  end loop;
end $$;

-- Verificación: las tres deben dar 0.
select (select count(*) from pg_tables where schemaname = 'public') as tablas,
       (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public') as funciones,
       (select count(*) from pg_type t join pg_namespace n on n.oid = t.typnamespace where n.nspname = 'public' and t.typtype = 'e') as tipos;
