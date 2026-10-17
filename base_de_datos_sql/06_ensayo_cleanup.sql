-- 06: borra el evento de ensayo y todo lo que cuelga de el (tripulaciones, PE, tiempos y resultados).
delete from public.events where name like 'ENSAYO%';

-- Despues, volve a dejar en vivo el evento real (ajusta el nombre si hace falta):
-- update public.events set is_live = true where name like '3ª fecha%' and name not like 'ENSAYO%';
