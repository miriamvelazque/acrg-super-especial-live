-- =====================================================================
-- Inscriptos SÚPER ESPECIAL - ACRG (22 tripulaciones, según la planilla de largada)
-- Ejecutar DESPUÉS de 11_evento_super_especial_acrg.sql. Re-ejecutable (actualiza por nº de auto).
-- El "Piloto Inv." (11 tripulaciones) va dentro de la columna navegante: "Navegante (Inv: Nombre)".
-- =====================================================================
insert into crews (event_id, car_number, category, driver, co_driver, car_model)
select e.id, v.car_number, v.category, v.driver, v.co_driver, v.car_model
from events e,
(values
  ('A-B', 205, 'De Souza Cristian', 'Rojas Manuel (Inv: Yess Tobias)', 'Lada Samara'),
  ('A-B', 202, 'Miranda Leandro', 'Petrone Francisco', 'Fiat 147'),
  ('A-B', 203, 'Paillan Patricio', 'Capello Renata (Inv: Oroz Nicolas)', 'Lada Samara'),
  ('C', 204, 'Medina Damian', 'Cardozo Joaquin', 'VW Gol G1'),
  ('C', 304, 'Gonzalez Manuel', 'Felder Leonardo', 'VW Gol G1'),
  ('C', 306, 'Leal Francisco', 'Strongoli Emmanuel (Inv: Vidal Sebastian)', 'VW Senda'),
  ('C1', 910, 'Raimilla Marcelo', 'Raimilla Daniel (Inv: Raimilla Matias)', 'VW Gol 1.4'),
  ('C1', 301, 'Soto Mateo', 'Peix Juliana (Inv: Saldivia Matias)', 'Chevrolet Onix 1.4'),
  ('C1', 911, 'Torino Gabriel', 'Esteban Stork (Inv: Stork Esteban)', 'Chevrolet Celta 1.4'),
  ('C1', 909, 'Agüero Gabriel', 'Agüero Yamila (Inv: Agüero Emiliano)', 'VW Gol 1.4'),
  ('C1', 902, 'Toledo Facundo', 'Toledo Camila', 'VW Gol 1.4'),
  ('D', 409, 'Toloza Eduardo', 'Toloza Danilo - Mencia Daiana (Inv: Toloza Cristian)', 'Ford Fiesta KD'),
  ('D', 426, 'Barrenechea Ramiro', 'Borgato Candela (Inv: Barrenechea Abel)', 'VW Gol Trend'),
  ('D', 407, 'Leal Matias', 'Leal Tiziano', 'VW Gol 1.6'),
  ('D', 402, 'Jara Nicolas', 'Willer Ana', 'Ford Ka 1.6'),
  ('D', 406, 'Bahamonde Brandon', 'Bahamonde Braian', 'VW Gol 1.6'),
  ('D', 403, 'Herrera Rodrigo', 'Romero Roberto - Serafin Ivan (Inv: Garro Lucas)', 'Ford Ka 1.6'),
  ('E', 502, 'Blanco Sebastian', 'Romero Pablo (Inv: Arralde Luis)', 'Nissan March'),
  ('E', 503, 'Rega Nicolas', 'Carcamo Maria', 'Nissan March'),
  ('E', 504, 'Collante Emmanuel', 'Oyarzun Milton', 'Toyota Etios'),
  ('F', 703, 'Alvarez Tomas', 'Medina Pablo', 'VW Gol 1.6'),
  ('F', 608, 'Perez Luis', 'Oyarzo Agustin', 'VW Gol 1.6')
) as v(category, car_number, driver, co_driver, car_model)
where e.name = 'SÚPER ESPECIAL - ACRG'
on conflict (event_id, car_number) do update
  set category = excluded.category, driver = excluded.driver,
      co_driver = excluded.co_driver, car_model = excluded.car_model;

-- Verificación: deben ser 22.
select count(*) as tripulaciones from crews c join events e on e.id = c.event_id where e.name = 'SÚPER ESPECIAL - ACRG';
