-- 3.1.1. Agrupación de coberturas por polígono.
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
unnest AS(
	--First level don't need to unnest
	SELECT id_polygon, siose_code, docs#>'{polygon,cover}' AS elements
	FROM polygons
),
unnest1 AS(
	SELECT id_polygon, siose_code, 
		jsonb_array_elements(elements#>'{cover}') as elements FROM unnest
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
	SELECT * FROM unnest
	UNION
	SELECT * FROM unnest1
	UNION
	SELECT * FROM unnest2
	UNION	
	SELECT * FROM unnest3
)

SELECT id_polygon, (elements->>'-id') AS id_cover, SUM((elements->>'-area_perc')::double precision) AS sum_area_perc ,SUM((elements->>'-area_ha')::double precision) AS sum_area_ha
FROM bind
GROUP BY id_polygon, id_cover
ORDER BY id_polygon;