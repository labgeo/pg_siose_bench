--3.3.4. Selección de polígonos que contengan un atributo o el otro.
--40 - plantación
--46 - procecencia de cultivos
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m
	WHERE gid = 2
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
)

SELECT DISTINCT v.id_polygon
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) 
AND (v.attributes @> ARRAY[46] OR v.attributes @> ARRAY[40])