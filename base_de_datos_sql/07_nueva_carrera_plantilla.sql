-- 07: PLANTILLA PARA CARGAR UNA CARRERA NUEVA (Rally Fueguino A.PI.TU.R. - Live Timing)
-- Se corre en Supabase > SQL Editor, DESPUES de 01 y 02. Copiar este archivo, completar y correr.
-- Todos los tiempos de la base van en centesimas; aca no se cargan tiempos, solo la estructura de la carrera.
-- Roles validos (app_role): timekeeper (carga), commissioner (valida/reabre), admin (todo).

-- PASO 1 - Evento + etapas + PE + tripulaciones, todo de una vez.
-- Completar lo que dice MAYUSCULAS y las fechas. special_stages.status arranca solo en 'pending'.
do $$
declare
  v_event  uuid;
  v_etapa1 uuid;
  v_etapa2 uuid;
begin
  insert into public.events (name, venue, starts_on, ends_on, is_live)
  values ('4ª FECHA NOMBRE DE LA CARRERA', 'SEDE', '2026-11-14', '2026-11-15', false)
  returning id into v_event;

  insert into public.stages (event_id, number, name, stage_date)
  values (v_event, 1, 'Etapa 1', '2026-11-14') returning id into v_etapa1;
  insert into public.stages (event_id, number, name, stage_date)
  values (v_event, 2, 'Etapa 2', '2026-11-15') returning id into v_etapa2;

  -- Las PE se numeran corridas por evento (PE1, PE2... sin reiniciar en la Etapa 2).
  -- Ajustar a que etapa pertenece cada PE segun el recorrido oficial.
  insert into public.special_stages (event_id, stage_id, number, name) values
    (v_event, v_etapa1, 1, 'PE1'),
    (v_event, v_etapa1, 2, 'PE2'),
    (v_event, v_etapa1, 3, 'PE3'),
    (v_event, v_etapa1, 4, 'PE4'),
    (v_event, v_etapa2, 5, 'PE5'),
    (v_event, v_etapa2, 6, 'PE6'),
    (v_event, v_etapa2, 7, 'PE7'),
    (v_event, v_etapa2, 8, 'PE8');

  -- Tripulaciones: numero, piloto, navegante, categoria, marca/modelo, peña. Los dos ultimos pueden ir en null.
  -- El numero de auto no se puede repetir dentro del evento.
  insert into public.crews (event_id, car_number, driver, co_driver, category, car_model, team) values
    (v_event, 733, 'OJEDA JOAQUIN',   'OJEDA MARTIN', 'F', null, null),
    (v_event, 711, 'ALVAREZ MARCELO', 'MEDINA PABLO', 'F', null, 'BY ALVAREZ'),
    (v_event, 422, 'PAVLOV IGNACIO',  'PAVLOV EMILIO', 'D', null, null);
    -- una linea por auto, separadas por coma; la ultima termina con punto y coma.
end $$;

-- PASO 2 - Dejar la carrera nueva "en vivo". La web publica y el panel muestran UN solo evento
-- en vivo: si hay dos con is_live = true, la web falla. Siempre se apagan los demas primero.
-- update public.events set is_live = false;
-- update public.events set is_live = true where name = '4ª FECHA NOMBRE DE LA CARRERA';

-- PASO 3 - Personal. Crear el usuario en Authentication > Users, copiar su UUID y completar.
-- Rol: 'timekeeper', 'commissioner' o 'admin'.
-- insert into public.staff_roles (user_id, role, display_name)
-- values ('UUID-DEL-USUARIO', 'timekeeper', 'NOMBRE PARA MOSTRAR');

-- Para ver el id del evento (lo necesita crews_plantilla.csv si importas por CSV):
-- select id, name, starts_on, is_live from public.events order by created_at desc;
