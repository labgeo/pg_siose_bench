--3.4.3. Superficie ocupada por una cobertura con un determinado atributo.
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m
	WHERE gid = 1
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
)

--There are polygons with 2 case of "CNFpl", but no DISTINCT is necessary
SELECT SUM(v.area_ha) AS total_area_CNFpl_Ha
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) 
AND v.id_cover=316 AND v.attributes @> ARRAY[40]

--ORDER BY p.id_polygon;