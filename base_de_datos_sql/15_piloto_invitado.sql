-- 15: columna "Piloto Inv." (piloto invitado) en las tripulaciones. Correr UNA vez, ANTES de volver a correr el 12.
-- No borra ni modifica datos existentes.
alter table public.crews add column if not exists inv_driver text;
