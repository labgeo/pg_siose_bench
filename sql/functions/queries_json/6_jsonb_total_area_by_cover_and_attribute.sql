--VARIANTE EN LA QUE SE HACE UN USO MINIMO DEL OPERADOR "LIKE"
--Más rápido y fácil que hacer 4 unnest más y joins para unir con los primeros 4 unnest!!!!!!!!

--Select polygons by cover and attribute descriptions
--TODO: Maybe same query based on codes instead of descriptions
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_1m 
	WHERE gid=1
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
	SELECT id_polygon, siose_code, 
		docs#>'{polygon,cover}' AS elements
	FROM polygons
	WHERE docs @> '{"polygon": {"cover": {"-id": "CNF", "attributes": [{"-id": "pl"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF", "attributes": [{"-id": "pl"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF","attributes": [{"-id": "pl"}]}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-id": "CNF", "attributes": [{"-id": "pl"}]}]}]}]}}}'
),
unnest1 AS(
	SELECT id_polygon, siose_code, 
		jsonb_array_elements(elements#>'{cover}') as elements FROM bfilter
),
unnest2 AS(
	SELECT id_polygon, siose_code, 
		jsonb_array_elements(elements#>'{cover}') as elements FROM unnest1
),
unnest3 AS(
	SELECT id_polygon, siose_code, 
		jsonb_array_elements(elements#>'{cover}') as elements FROM unnest2
),
bind AS(
	SELECT * FROM bfilter WHERE elements::text LIKE '%pl%'
	UNION
	SELECT * FROM unnest1 WHERE elements::text LIKE '%pl%'
	UNION
	SELECT * FROM unnest2 WHERE elements::text LIKE '%pl%'
	UNION	
	SELECT * FROM unnest3 WHERE elements::text LIKE '%pl%'
)

SELECT SUM((elements->>'-area_ha')::double precision)  AS total_area_CNFpl_Ha
FROM bind
WHERE elements->>'-id'='CNF'

--ORDER BY id_polygon


