-- =====================================================================
-- SÚPER ESPECIAL - ACRG (2ª fecha, 5º Campeonato Súper Especial)
-- Sábado 31/10/2026: Etapa 1 = PE1..PE3  |  Domingo 01/11/2026: Etapa 2 = PE4..PE8
-- Ejecutar en el SQL Editor de Supabase, DESPUÉS de 01, 02, 08, 09_nacionalidad_y_vehiculo y 10_trazabilidad.
-- Es re-ejecutable: no duplica nada.
-- =====================================================================
begin;

-- 1) Evento. Si el proyecto ya tiene otro evento en vivo, se apaga (la web muestra solo uno).
update events set is_live = false where is_live = true and name <> 'SÚPER ESPECIAL - ACRG';

insert into events (name, venue, starts_on, ends_on, is_live)
select 'SÚPER ESPECIAL - ACRG', 'Río Grande, Tierra del Fuego', date '2026-10-31', date '2026-11-01', true
where not exists (select 1 from events where name = 'SÚPER ESPECIAL - ACRG');

-- 2) Etapas: 1 = sábado 31/10, 2 = domingo 01/11.
insert into stages (event_id, number, name, stage_date)
select e.id, v.n, 'Etapa ' || v.n, v.d
from events e,
     (values (1, date '2026-10-31'), (2, date '2026-11-01')) as v(n, d)
where e.name = 'SÚPER ESPECIAL - ACRG'
  and not exists (select 1 from stages s where s.event_id = e.id and s.number = v.n);

-- 3) Pruebas Especiales: PE1-PE3 en Etapa 1, PE4-PE8 en Etapa 2 (numeración corrida por evento).
insert into special_stages (event_id, stage_id, number, name)
select e.id, s.id, p.n, 'PE' || p.n
from events e
join stages s on s.event_id = e.id
join (values (1,1),(2,1),(3,1),(4,2),(5,2),(6,2),(7,2),(8,2)) as p(n, stage_no) on p.stage_no = s.number
where e.name = 'SÚPER ESPECIAL - ACRG'
  and not exists (select 1 from special_stages x where x.event_id = e.id and x.number = p.n);

commit;

-- 4) Verificación: deben salir 8 filas (3 en Etapa 1 y 5 en Etapa 2).
select s.number as etapa, ss.number as pe, ss.name
from events e
join stages s on s.event_id = e.id
join special_stages ss on ss.stage_id = s.id
where e.name = 'SÚPER ESPECIAL - ACRG'
order by ss.number;
