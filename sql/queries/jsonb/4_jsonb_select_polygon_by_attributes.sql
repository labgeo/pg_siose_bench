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
	FROM siose.docstore_jsonb p, mapwindow 
	WHERE mapwindow.geom && p.geom
),
bfilter AS(
	SELECT *
	FROM polygons p
	WHERE docs @> '{"polygon": {"cover": {"attributes": [{"-id": "pc"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"attributes": [{"-id": "pc"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"attributes": [{"-id": "pc"}]}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"attributes": [{"-id": "pc"}]}]}]}]}}}'

	OR docs @> '{"polygon": {"cover": {"attributes": [{"-id": "pl"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"attributes": [{"-id": "pl"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"attributes": [{"-id": "pl"}]}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"attributes": [{"-id": "pl"}]}]}]}]}}}'
)
SELECT id_polygon FROM bfilter; --El DISTINCT no hace falta si vamos de celda en celda