-- Borra los tiempos de ENSAYO del evento SÚPER ESPECIAL - ACRG (deja evento, PE e inscriptos).
-- Correr justo antes de la carrera. El trigger vacía también la tabla pública "results".
delete from time_entries
where special_stage_id in (
  select ss.id from special_stages ss join events e on e.id = ss.event_id
  where e.name = 'SÚPER ESPECIAL - ACRG');

-- Verificación: ambas deben dar 0.
select (select count(*) from time_entries) as time_entries, (select count(*) from results) as results;
