-- Usuarios del personal SÚPER ESPECIAL - ACRG.
-- 1) En Supabase > Authentication > Users > Add user: crear cada usuario con email + contraseña
--    (tildar "Auto Confirm User"). Podés usar emails inventados (ej: crono1@acrg.local).
-- 2) Reemplazar los EMAIL-... de abajo por los emails reales y ejecutar.
-- display_name = el USUARIO que se escribe para entrar a /admin (08_login_por_usuario.sql).
-- Rol 'commissioner': carga Y publica directo (con AUTO_VALIDAR = true en admin.html no hace falta validar).
insert into public.staff_roles (user_id, role, display_name)
select id, 'commissioner', 'Cronometrista 1' from auth.users where email = 'EMAIL-CRONOMETRISTA-1'
on conflict (user_id) do update set role = excluded.role, display_name = excluded.display_name;

insert into public.staff_roles (user_id, role, display_name)
select id, 'commissioner', 'Cronometrista 2' from auth.users where email = 'EMAIL-CRONOMETRISTA-2'
on conflict (user_id) do update set role = excluded.role, display_name = excluded.display_name;

-- Administrador (vos): puede todo, incluida la limpieza de pruebas.
insert into public.staff_roles (user_id, role, display_name)
select id, 'admin', 'Admin' from auth.users where email = 'EMAIL-ADMIN'
on conflict (user_id) do update set role = excluded.role, display_name = excluded.display_name;

-- Verificación
select s.display_name as usuario, s.role, u.email from public.staff_roles s join auth.users u on u.id = s.user_id order by s.display_name;
