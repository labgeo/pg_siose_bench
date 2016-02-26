--3.2.5. Selección de polígonos con una cobertura de superficie determinada.
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m 
	WHERE gid = 5
),
polygons AS(
	SELECT *
	FROM siose.docstore_jsonb p, mapwindow 
	WHERE mapwindow.geom && p.geom
),
--Now unnest every possible level
--In the relational docker
--SELECT MAX(array_length(id_parents,1)) FROM siose.siose_values  ===> 3 (zero based arrays)
bfilter AS(
	--First level don't need to unnest
	SELECT id_polygon, --siose_code, 
		docs#>'{polygon,cover}' AS elements
	FROM polygons
	WHERE docs @> '{"polygon": {"cover": {"-id": "CNF"}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-id": "CNF"}]}]}]}}}'
),
unnest1 AS(
	SELECT id_polygon, --siose_code, 
		jsonb_array_elements(elements#>'{cover}') as elements FROM bfilter
),
unnest2 AS(
	SELECT id_polygon, --siose_code, 
		jsonb_array_elements(elements#>'{cover}') as elements FROM unnest1
),
unnest3 AS(
	SELECT id_polygon, --siose_code, 
		jsonb_array_elements(elements#>'{cover}') as elements FROM unnest2
),
bind AS(
	SELECT * FROM bfilter
	UNION
	SELECT * FROM unnest1
	UNION
	SELECT * FROM unnest2
	UNION	
	SELECT * FROM unnest3
)

--Distinct is necessary only when one polygon has two CNF covers over 1Ha. Very weird!!
SELECT DISTINCT id_polygon--, siose_code--elements->>'-desc', (elements->>'-area_perc')::numeric
FROM bind
WHERE elements->>'-id'='CNF' AND (elements->>'-area_ha')::numeric > 1

