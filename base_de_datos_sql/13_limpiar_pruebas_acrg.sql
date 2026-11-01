-- Borra los tiempos de PRUEBA de la ETAPA 2 (PE4 a PE8) y su historial. NO toca la Etapa 1.
-- Correr antes de largar el domingo, después de probar en vivo. (Con Admin o desde el SQL Editor.)
delete from time_entries
where special_stage_id in (
  select ss.id from special_stages ss join events e on e.id = ss.event_id
  where e.name = 'SÚPER ESPECIAL - ACRG' and ss.number >= 4);

delete from time_entries_log
where special_stage_id in (
  select ss.id from special_stages ss join events e on e.id = ss.event_id
  where e.name = 'SÚPER ESPECIAL - ACRG' and ss.number >= 4);

-- Verificación: debe dar 0 (la Etapa 1 queda intacta).
select count(*) as tiempos_etapa_2
from time_entries te join special_stages ss on ss.id = te.special_stage_id where ss.number >= 4;
