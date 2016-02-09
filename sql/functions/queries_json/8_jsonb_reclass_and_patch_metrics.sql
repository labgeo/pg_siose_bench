--3.2.1. Reclass and patch metrics
-- 316 - Coniferous
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m
	WHERE gid = 15
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

SELECT densclas AS density_classification, COUNT(densclas) AS patches, SUM(sum) AS area_ha FROM 

((SELECT id_polygon, '1.- Low density' AS densclas, SUM((elements->>'-area_ha')::double precision)
FROM bind
WHERE elements->>'-id'='CNF' AND (elements->>'-area_perc')::double precision BETWEEN 0 AND 25
GROUP BY id_polygon)

UNION

(SELECT id_polygon, '2.- Medium density' AS densclas, SUM((elements->>'-area_ha')::double precision)
FROM bind
WHERE elements->>'-id'='CNF' AND (elements->>'-area_perc')::double precision BETWEEN 25 AND 50
GROUP BY id_polygon)

UNION

(SELECT id_polygon, '3.- High density' AS densclas, SUM((elements->>'-area_ha')::double precision)
FROM bind
WHERE elements->>'-id'='CNF' AND (elements->>'-area_perc')::double precision BETWEEN 50 AND 75
GROUP BY id_polygon)

UNION

(SELECT id_polygon, '4.- Very high density' AS densclas, SUM((elements->>'-area_ha')::double precision)
FROM bind
WHERE elements->>'-id'='CNF' AND (elements->>'-area_perc')::double precision BETWEEN 75 AND 100
GROUP BY id_polygon)) AS reclass

GROUP BY densclas
ORDER BY density_classification ASC;