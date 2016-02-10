--Select polygons by cover and attribute descriptions
--TODO: Maybe same query based on codes instead of descriptions
WITH mapwindow AS(
	SELECT * 
	FROM siose.spain_grid_100k 
	WHERE gid=6
),
polygons AS(
	SELECT * 
	FROM siose.siose_polygons p, mapwindow 
	WHERE st_intersects(mapwindow.geom, p.geom)
),
lookup AS (

	SELECT
		sp.id_polygon,

		cover_desc,
		siose.table_lookup(attributes,'siose.siose_attributes'::regclass, 'id_attribute','attribute_desc') AS attribute_desc

	FROM polygons AS sp

	JOIN siose.siose_values AS sv ON sp.id_polygon=sv.id_polygon
	JOIN siose.siose_coverages AS sc ON sc.id_cover=sv.id_cover
)

SELECT DISTINCT id_polygon FROM lookup WHERE cover_desc='Matorral' AND attribute_desc@> ARRAY['procedencia de cultivos'];
