-- SÚPER ESPECIAL ACRG - Live Timing - 09: nacionalidad (bandera) en la pestana Inscriptos
-- Ejecutar UNA vez en Supabase > SQL Editor. No borra ni modifica datos existentes.
-- Codigo de pais de 2 letras (ISO): AR, CL, BR, UY, PY, BO, PE, CO, US, ES, IT...
-- nationality = piloto, co_nationality = navegante. Todas las tripulaciones quedan en AR por defecto.

alter table public.crews
  add column if not exists nationality    text default 'AR',
  add column if not exists co_nationality text default 'AR';

-- Ejemplos (cambiar el numero de auto / los valores):
-- Vehiculo: el logo sale de la primera palabra del modelo ("Ford Fiesta" -> ford.png)
-- update public.crews set car_model = 'Ford Fiesta'
--   where event_id = (select id from public.events where is_live) and car_number = 711;
-- Piloto chileno con navegante argentino:
-- update public.crews set nationality = 'CL'
--   where event_id = (select id from public.events where is_live) and car_number = 733;
