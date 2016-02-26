--3.2.4. Selección de polígonos que contengan una cobertura dentro de otra.
-- 101 - Edificaciones
-- 813 - Urbano discontinuo
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m
	WHERE gid = 12
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
)

SELECT DISTINCT v.id_polygon
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) AND v.id_cover=101 AND v.id_parents @> ARRAY[813];


--SELECT siose_code FROM siose.siose_polygons WHERE siose_code LIKE '%CNF%' AND siose_code LIKE '%UDS%' ORDER BY length(siose_code) DESC