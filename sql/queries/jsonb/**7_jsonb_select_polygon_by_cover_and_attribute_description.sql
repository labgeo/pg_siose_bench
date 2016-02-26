--Select polygons by cover and attribute descriptions
--TODO: Maybe same query based on codes instead of descriptions
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_100k 
	WHERE gid=6
),
polygons AS(
	SELECT *
	FROM siose.docstore_jsonb p, mapwindow 
	WHERE mapwindow.geom && p.geom
),
bfilter AS(
	SELECT *
	FROM polygons p
	WHERE docs @> '{"polygon": {"cover": {"-desc": "Matorral", "attributes": [{"-desc": "procedencia de cultivos"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-desc": "Matorral", "attributes": [{"-desc": "procedencia de cultivos"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-desc": "Matorral","attributes": [{"-desc": "procedencia de cultivos"}]}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-desc": "Matorral", "attributes": [{"-desc": "procedencia de cultivos"}]}]}]}]}}}'
)
SELECT id_polygon FROM bfilter