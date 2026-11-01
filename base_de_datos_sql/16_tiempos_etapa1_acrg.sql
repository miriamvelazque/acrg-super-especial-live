-- =====================================================================
-- Tiempos OFICIALES de la ETAPA 1 (sábado 31/10) - SÚPER ESPECIAL ACRG: PE1 a PE3 x 22 tripulaciones.
-- Fuente: planilla de tiempos publicada por el ACRG (Rulo 1 S / 2 S / 3 S).
-- Correr DESPUÉS de 11 y 12. Queda publicado en la web al instante (validated = true). Re-ejecutable.
--
-- CONVENCIÓN (la planilla solo trae el tiempo de cada rulo, no las horas de largada/llegada):
--   largada = 00:00:00,00  y  llegada = tiempo del rulo (menos la penalización, si la hay).
--   Esas horas son SINTÉTICAS: solo el tiempo neto es real. El historial las muestra como "SQL Editor / sistema".
-- Celdas amarillas "PEOR TIEMPO + 10" de la planilla (502 en PE1; 608 en PE1, PE2 y PE3):
--   se cargan como el peor tiempo + penalización de 10,00 s, de modo que el neto coincide con la planilla.
-- Columnas de VALUES: (PE, nº de auto, base_cs, penalizacion_cs). Tiempo neto = base + penalización.
-- =====================================================================
insert into time_entries (special_stage_id, crew_id, status, start_cs, finish_cs, penalty_cs, validated)
select ss.id, c.id, 'ok', 0, v.base_cs, v.pen_cs, true
from events e
join (values
  (1, 205, 21270, 0),
  (2, 205, 21483, 0),
  (3, 205, 21283, 0),
  (1, 202, 21168, 0),
  (2, 202, 22079, 0),
  (3, 202, 21106, 0),
  (1, 203, 24379, 0),
  (2, 203, 21956, 0),
  (3, 203, 22065, 0),
  (1, 204, 21714, 0),
  (2, 204, 21073, 0),
  (3, 204, 20974, 0),
  (1, 304, 20873, 0),
  (2, 304, 20605, 0),
  (3, 304, 20092, 0),
  (1, 306, 20902, 0),
  (2, 306, 20433, 0),
  (3, 306, 20443, 0),
  (1, 910, 21295, 0),
  (2, 910, 20846, 0),
  (3, 910, 19993, 0),
  (1, 301, 19962, 0),
  (2, 301, 19866, 0),
  (3, 301, 19472, 0),
  (1, 911, 20004, 0),
  (2, 911, 20234, 0),
  (3, 911, 19459, 0),
  (1, 909, 20573, 0),
  (2, 909, 20355, 0),
  (3, 909, 20479, 0),
  (1, 902, 20065, 0),
  (2, 902, 19709, 0),
  (3, 902, 19545, 0),
  (1, 409, 22286, 0),
  (2, 409, 21308, 0),
  (3, 409, 20001, 0),
  (1, 426, 21251, 0),
  (2, 426, 20924, 0),
  (3, 426, 20251, 0),
  (1, 407, 20246, 0),
  (2, 407, 19961, 0),
  (3, 407, 19638, 0),
  (1, 402, 19518, 0),
  (2, 402, 19496, 0),
  (3, 402, 18894, 0),
  (1, 406, 20913, 0),
  (2, 406, 19730, 0),
  (3, 406, 19685, 0),
  (1, 403, 19803, 0),
  (2, 403, 19357, 0),
  (3, 403, 18976, 0),
  (1, 502, 20659, 1000),
  (2, 502, 19367, 0),
  (3, 502, 19093, 0),
  (1, 503, 19813, 0),
  (2, 503, 19306, 0),
  (3, 503, 19136, 0),
  (1, 504, 20659, 0),
  (2, 504, 20181, 0),
  (3, 504, 19861, 0),
  (1, 703, 18954, 0),
  (2, 703, 18395, 0),
  (3, 703, 18342, 0),
  (1, 608, 18954, 1000),
  (2, 608, 18395, 1000),
  (3, 608, 18342, 1000)
) as v(pe, car, base_cs, pen_cs) on true
join special_stages ss on ss.event_id = e.id and ss.number = v.pe
join crews c on c.event_id = e.id and c.car_number = v.car
where e.name = 'SÚPER ESPECIAL - ACRG'
on conflict (special_stage_id, crew_id) do update
  set status = 'ok', start_cs = excluded.start_cs, finish_cs = excluded.finish_cs,
      penalty_cs = excluded.penalty_cs, validated = true;

-- Verificación 1: debe dar 66 (22 autos x 3 PE) en ambas.
select (select count(*) from time_entries te join special_stages ss on ss.id = te.special_stage_id
        join events e on e.id = ss.event_id where e.name = 'SÚPER ESPECIAL - ACRG' and ss.number <= 3) as time_entries,
       (select count(*) from results r join events e on e.id = r.event_id
        where e.name = 'SÚPER ESPECIAL - ACRG') as publicados;

-- Verificación 2: compara con el "Tiempo general sábado" oficial. Debe devolver CERO filas.
with oficial(car, total_cs) as (values
  (205, 64036),
  (202, 64353),
  (203, 68400),
  (204, 63761),
  (304, 61570),
  (306, 61778),
  (910, 62134),
  (301, 59300),
  (911, 59697),
  (909, 61407),
  (902, 59319),
  (409, 63595),
  (426, 62426),
  (407, 59845),
  (402, 57908),
  (406, 60328),
  (403, 58136),
  (502, 60119),
  (503, 58255),
  (504, 60701),
  (703, 55691),
  (608, 58691)
)
select o.car, o.total_cs as oficial_cs, coalesce(sum(r.net_cs), 0) as cargado_cs
from oficial o
left join crews c on c.car_number = o.car and c.event_id = (select id from events where name = 'SÚPER ESPECIAL - ACRG')
left join results r on r.crew_id = c.id
group by o.car, o.total_cs
having coalesce(sum(r.net_cs), 0) <> o.total_cs;
