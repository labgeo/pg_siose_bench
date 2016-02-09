--3.2.4. Selección de polígonos que contengan una cobertura dentro de otra.
-- 111 - Otras construcciones
-- 912 - Conducciones y canales
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_500k
	WHERE gid = 19
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
	docs @> '{"polygon": {"cover": {"-id": "NCC", "cover": [{"-id": "OCT"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "NCC", "cover": [{"-id": "OCT"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "NCC", "cover":[{"-id": "OCT"}]}]}]}}}'
)

SELECT id_polygon FROM bfilter;


