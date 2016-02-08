--3.2.1. Reclass and patch metrics
-- 316 - Coniferous
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_100k 
	WHERE gid = 4
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE mapwindow.geom && p.geom
)


SELECT densclas AS density, COUNT(densclas) AS patches, SUM(sum) AS area_ha FROM 

((SELECT v.id_polygon, '1.- Low density' AS densclas, SUM(v.area_ha)
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) AND v.id_cover=316
AND v.area_perc BETWEEN 0 AND 25
GROUP BY v.id_polygon)

UNION ALL

(SELECT v.id_polygon, '2.- Medium density' AS densclas, SUM(v.area_ha)
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) AND v.id_cover=316
AND v.area_perc BETWEEN 25 AND 50
GROUP BY v.id_polygon)

UNION ALL

(SELECT v.id_polygon, '3.- High density' AS densclas, SUM(v.area_ha)
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) AND v.id_cover=316
AND v.area_perc BETWEEN 50 AND 75
GROUP BY v.id_polygon)

UNION ALL

(SELECT v.id_polygon, '4.- Very high density' AS densclas, SUM(v.area_ha)
FROM siose.siose_values v, polygons p
WHERE v.id_polygon IN (p.id_polygon) AND v.id_cover=316
AND v.area_perc BETWEEN 75 AND 100
GROUP BY v.id_polygon)) AS reclass

GROUP BY densclas;

