--3.4.3. Superficie ocupada por una cobertura con un determinado atributo.
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_500k 
	WHERE gid = 15
),
polygons AS(
	SELECT *
	FROM siose.docstore_jsonb p, mapwindow 
	WHERE mapwindow.geom && p.geom
),
bfilter AS(
	SELECT *
	FROM polygons
	WHERE docs @> '{"polygon": {"cover": {"-id": "CNF", "attributes": [{"-id": "pl"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF", "attributes": [{"-id": "pl"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF", "attributes": [{"-id": "pl"}]}]}]}}}'
),
unnest AS(
	SELECT *, docs -> 'polygon' -> 'cover' as elements FROM bfilter
	UNION
	SELECT *, jsonb_array_elements(docs -> 'polygon' -> 'cover' -> 'cover') as elements FROM bfilter
	UNION
	SELECT *, jsonb_array_elements(docs -> 'polygon' -> 'cover' -> 'cover'-> 'cover') as elements FROM bfilter
)

SELECT *, elements->>'-desc', elements->>'-area_ha',length(siose_code)
FROM unnest
WHERE elements->>'-id'='CNF' -- AND attribute = 40