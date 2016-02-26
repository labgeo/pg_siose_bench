--3.2.1. Selección de polígonos por una única cobertura.
-- 316 - Coniferas
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m
	WHERE gid = 9
),
polygons AS(
	SELECT *
	FROM siose.docstore_jsonb p, mapwindow 
	WHERE mapwindow.geom && p.geom
),
bfilter AS(
	SELECT *
	FROM polygons
	WHERE docs @> '{"polygon": {"cover": {"-id": "CNF"}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-id": "CNF"}]}]}]}}}'
)
SELECT id_polygon FROM bfilter