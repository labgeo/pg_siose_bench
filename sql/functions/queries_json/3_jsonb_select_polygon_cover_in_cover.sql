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
	FROM siose.docstore_jsonb p, mapwindow 
	WHERE mapwindow.geom && p.geom
),
bfilter AS(
	SELECT *
	FROM polygons
	WHERE 
	docs @> '{"polygon": {"cover": {"-id": "UDS", "cover": [{"-id": "EDF"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "UDS", "cover": [{"-id": "EDF"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "UDS", "cover":[{"-id": "EDF"}]}]}]}}}'
)

SELECT id_polygon FROM bfilter;


