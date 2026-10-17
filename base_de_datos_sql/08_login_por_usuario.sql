-- Rally Fueguino A.PI.TU.R. - 08: login por NOMBRE DE USUARIO (en vez de email)
-- Ejecutar UNA vez en Supabase > SQL Editor. No modifica tablas ni datos existentes.
-- El nombre de usuario es staff_roles.display_name (ej: 'Cronometrista 1', 'Cronometrista 2', 'Comisario Deportivo').

-- 1) Que no haya dos usuarios con el mismo nombre (sin distinguir mayusculas ni espacios de los costados).
create unique index if not exists staff_roles_display_name_uq
  on public.staff_roles (lower(trim(display_name)));

-- 2) Traduce el nombre al email con el que se creo el usuario en Authentication.
create or replace function public.login_email(p_username text) returns text
language sql stable security definer set search_path = public, auth as $$
  select u.email::text
  from public.staff_roles s join auth.users u on u.id = s.user_id
  where lower(trim(s.display_name)) = lower(trim(p_username))
  limit 1;
$$;
revoke all on function public.login_email(text) from public;
grant execute on function public.login_email(text) to anon, authenticated;

-- 3) Ponerle nombre a los usuarios existentes (reemplazar los emails por los reales):
-- update public.staff_roles set display_name = 'Cronometrista 1'
--   where user_id = (select id from auth.users where email = 'EMAIL-DEL-CRONOMETRISTA');
-- update public.staff_roles set display_name = 'Comisario Deportivo'
--   where user_id = (select id from auth.users where email = 'EMAIL-DEL-COMISARIO');
-- select s.display_name, s.role, u.email from public.staff_roles s join auth.users u on u.id = s.user_id;
