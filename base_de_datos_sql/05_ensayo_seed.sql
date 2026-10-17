-- 05: DATOS DE ENSAYO. 22 tripulaciones reales (PDF de la 3ª fecha) + tiempos para probar el flujo completo.
-- Ejecutar en el SQL Editor de Supabase, DESPUES de 01 y 02. Crea un evento aparte "ENSAYO" y lo deja en vivo
-- (apaga is_live de los demas). Para borrar todo y volver al evento real: ejecutar 06_ensayo_cleanup.sql.
--
-- Que vas a ver en la web publica:
--   * PE1 a PE6: validadas para los 22 autos.
--   * PE7: validada solo para los primeros 12 autos de la clasificacion (733 a 411). El resto la tiene cargada
--     pero SIN validar, asi que el publico los ve con 6/7 PE (pendientes, atenuados) y los del panel ven "Sin validar".
--   * Auto 311: DNF validado en PE7 (queda al final, sin sumar).
--   * Auto 733: penalizacion de 10 s en PE3 (se muestra +0:10.00; el tiempo neto no cambia).
--   * PE8: sin cargar. Cargala vos desde admin.html para probar el tiempo real.
-- Las horas de largada/llegada son inventadas (escalonadas cada 2 minutos); el tiempo neto es el real del PDF.

update public.events set is_live = false;

do $$
declare v_ev uuid;
begin
  insert into public.events (name, venue, starts_on, ends_on, is_live)
  values ('ENSAYO - 3ª fecha Río Grande, 31º Campeonato Fueguino de Rally', 'Río Grande', '2026-10-03', '2026-10-04', true)
  returning id into v_ev;

  insert into public.stages (event_id, number, name, stage_date)
  select v_ev, n, 'Etapa ' || n, date '2026-10-02' + n from generate_series(1,2) n;

  insert into public.special_stages (event_id, stage_id, number, name, status)
  select v_ev, s.id, pe, 'PE' || pe, 'finished'
  from public.stages s
  join generate_series(1,8) pe on (s.number = 1 and pe <= 4) or (s.number = 2 and pe > 4)
  where s.event_id = v_ev;

  create temp table _seed (idx serial, car int, cat text, driver text, co text, team text, t int[]) on commit drop;
  insert into _seed (car, cat, driver, co, team, t) values
    (733,'F','OJEDA JOAQUIN','OJEDA MARTIN',null,array[23225,48155,46753,61398,62231,65817,67811,22265]),
    (711,'F','ALVAREZ MARCELO','MEDINA PABLO','BY ALVAREZ',array[22977,48014,46588,63491,61714,65324,67223,22614]),
    (422,'D','PAVLOV IGNACIO','PAVLOV EMILIO',null,array[23027,48040,46880,61674,62261,65799,68677,23043]),
    (418,'D','VILLARROEL MATIAS','GARCIA FRANCO',null,array[23756,48138,47146,62359,61857,66483,69086,23296]),
    (511,'RC-E','PRETO DANIEL','GARRO MARCELO',null,array[23521,48749,46780,63103,62410,67213,67523,22827]),
    (703,'F','ALVAREZ HUGO','COLIAGUE LEO','MECANICA ALVAREZ',array[23480,49078,47447,62130,62397,67096,69165,22234]),
    (702,'F','CARLETTI SANTINO','BARRIENTOS JUAN MANUEL',null,array[23536,47715,49891,62028,61956,66536,68658,23113]),
    (508,'RC-E','DE AMUCHATEGUI MATIAS','MELOGNO FACUNDO','LEYMI',array[22813,58305,46792,62790,62467,63974,66862,22809]),
    (708,'F','PARUN DANIEL','ALMONACID FRANCISCO',null,array[24255,47887,46143,61879,66301,65136,67273,22528]),
    (421,'D','CHEBEL NIKOLAS','AUSTIN TREVOR',null,array[24352,49640,47603,63484,63056,68676,71906,23475]),
    (408,'D','SALDIVIA MATIAS','ROMERO ROBERTO',null,array[24190,49977,47908,64371,64034,70621,72149,24338]),
    (411,'D','VELAZQUEZ FEDERICO','VELAZQUEZ FACUNDO','VZ RACING',array[24549,51041,48980,65365,66005,70425,70853,23990]),
    (401,'D','SUAREZ PATRICIO','GUERRERO ALVARO',null,array[23605,48749,46352,85644,62223,66730,69796,23030]),
    (315,'C1','SENKOVIC ALAN','SENKOVIC GABRIELA',null,array[23873,51428,49519,67575,66684,72867,73280,23477]),
    (302,'C1','TOLEDO CARLOS','MACHADO MATIAS',null,array[24858,51762,50658,68159,67882,71983,73930,24324]),
    (311,'C1','SOTO MATEO','PEIX JULIANA',null,array[24939,53358,50839,67603,68018,71388,74710,25543]),
    (426,'D','BARRENECHEA RAMIRO','BORGATO CANDELARIA','LOS PESADOS',array[24649,53671,49679,68860,66915,74534,74374,24497]),
    (404,'D','PRETO MORENO','DE ROBLES GUSTAVO',null,array[25537,52891,50376,69410,68996,71488,73593,24240]),
    (344,'C1','RUMACHELLA GASTON','IGOR JUAN',null,array[28053,54099,51048,68210,68647,73208,73824,24691]),
    (314,'C1','TORINO GABRIEL','LIPORACE LUIS',null,array[24436,52893,51872,70690,71888,72402,74133,24528]),
    (305,'C1','SOSA EMANUEL','SOSA ALDO','SOSA',array[26928,53883,51842,68515,70136,74796,75843,25600]),
    (318,'C1','VON MUNDHARDT EMANUEL','VARGAS FEDERICO',null,array[27096,61068,53939,73175,72471,75638,89565,25167]);

  insert into public.crews (event_id, car_number, driver, co_driver, category, team)
  select v_ev, car, driver, co, cat, team from _seed;

  -- Una fila por auto y PE. Para PE8 no se carga nada.
  insert into public.time_entries (special_stage_id, crew_id, status, start_cs, finish_cs, penalty_cs, validated)
  select ss.id, c.id,
         case when d.dnf then 'dnf'::public.entry_status else 'ok'::public.entry_status end,
         case when d.dnf then null else d.start_cs end,
         case when d.dnf then null else d.start_cs + sd.t[ss.number] - d.pen end,   -- neto = llegada - largada + penalizacion = tiempo del PDF
         case when d.dnf then 0 else d.pen end,
         (ss.number <= 6) or (ss.number = 7 and (sd.idx <= 12 or sd.car = 311))
  from _seed sd
  join public.crews c on c.event_id = v_ev and c.car_number = sd.car
  join public.special_stages ss on ss.event_id = v_ev and ss.number <= 7
  cross join lateral (select
      (9*3600 + (ss.number - 1)*3600 + (sd.idx - 1)*120) * 100 as start_cs,
      (sd.car = 311 and ss.number = 7) as dnf,
      case when sd.car = 733 and ss.number = 3 then 1000 else 0 end as pen) d;
end $$;
