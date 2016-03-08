
CREATE OR REPLACE FUNCTION relational.json_builder(text)
  RETURNS json AS
$BODY$


DECLARE
script text;
siose_object json;

BEGIN

script:= $literal$

WITH RECURSIVE load_data AS (

	SELECT
		sp.id_polygon,
		siose_code,
		inter_id as id,

		COALESCE(sv.inter_parents[array_length(sv.inter_parents,1)], 0) AS parent, --Last element in path is the one this depends on
		COALESCE(sv.inter_parents, '{0}') AS path, --Ordered array containing full path to the current cover

		cover_code,
		cover_desc,

		relational.table_lookup(attributes,'relational.siose_attributes'::regclass, 'id_attribute','attribute_code') AS attribute_codes,
		relational.table_lookup(attributes,'relational.siose_attributes'::regclass, 'id_attribute','attribute_desc') AS attribute_desc,

		area_ha,
		area_perc

	FROM relational.siose_polygons AS sp

	JOIN relational.siose_values AS sv ON sp.id_polygon=sv.id_polygon
	JOIN relational.siose_coverages AS sc ON sc.id_cover=sv.id_cover

	WHERE sp.id_polygon= %s
	ORDER BY inter_id),

hierarchy AS (--Calculate levels
	SELECT ld.id_polygon, ld.siose_code, ld.id, ld.parent, ld.path,
		ld.cover_code, ld.cover_desc, ld.attribute_codes, ld.attribute_desc,
		ld.area_ha, ld.area_perc, 0 AS level
	FROM load_data ld
	WHERE ld.parent = 0
	UNION ALL
	SELECT ld.id_polygon, ld.siose_code, ld.id, ld.parent, ld.path,
		ld.cover_code, ld.cover_desc, ld.attribute_codes, ld.attribute_desc,
		ld.area_ha, ld.area_perc, level + 1
	FROM load_data ld 
	JOIN hierarchy ON ld.parent = hierarchy.id
),

tree AS (
	SELECT 
		id_polygon, siose_code, id, parent, path,
		COALESCE (cover_code, attribute_codes[1]) AS cover_code,--Put A,R,I attribute codes in the cover_code column
		
		(CASE
			WHEN cover_code is NULL THEN attribute_desc[1]
			ELSE cover_desc
		END) AS cover_desc, --Put A,R,I attribute desc in the cover_desc column

		(CASE
			WHEN cover_code is NULL THEN '{NULL}'
			ELSE attribute_codes
		END) AS attribute_codes, --Remove A,R,I from attribute_codes

		(CASE
			WHEN cover_code is NULL THEN '{NULL}'
			ELSE attribute_desc
		END) AS attribute_desc, --Remove A,R,I from attribute_codes

		area_ha, area_perc, level
	FROM hierarchy)


/* BUILD JSON */
SELECT (

replace(
	replace(
		replace(
			replace(
			'{"polygon":{'
				||'"-id":'|| to_json(id_polygon)||','
				--||'"-code":'|| to_json(siose_code)||','--We don't want to keep this in the json, but it will be in the postgres table
				||'"cover":'
				||string_agg(json_covers,'')--Aggregate all rows
			||'}}'

			,',"cover":[]', ''),--Remove empty cover lists
		',{"-id":"","-desc":""}', ''),--Remove empty attributes preceded by comma
	'{"-id":"","-desc":""}', ''),--Remove empty attributes without comma
',"attributes":[]', '')--Remove empty attribute lists*/
	

	)::json AS siose_object 
FROM (
	SELECT	id_polygon, siose_code,
		'{"-id":'||to_json(cover_code)||','
		||'"-desc":' || to_json(cover_desc) ||','
		||'"-area_ha":' || to_json(area_ha) ||','
		||'"-area_perc":' || to_json(area_perc)||','
		||'"attributes":['
			||'{"-id":'|| to_json(COALESCE(attribute_codes[1],''))|| ',"-desc":'|| to_json(COALESCE(attribute_desc[1],'')) ||'},'
			||'{"-id":'|| to_json(COALESCE(attribute_codes[2],''))|| ',"-desc":'|| to_json(COALESCE(attribute_desc[2],'')) ||'},'
			||'{"-id":'|| to_json(COALESCE(attribute_codes[3],''))|| ',"-desc":'|| to_json(COALESCE(attribute_desc[3],'')) ||'},'
			||'{"-id":'|| to_json(COALESCE(attribute_codes[4],''))|| ',"-desc":'|| to_json(COALESCE(attribute_desc[4],'')) ||'}'
			||']'--end of attributes
			
		||',"cover":['
		||

		CASE lead( level, 1 ) OVER( ORDER BY id )
			WHEN level + 1 THEN '' -- There's children, add item array
			WHEN level THEN ']},' --same lavel, no children, only close
			ELSE -- last child in group start to close
		']}' || --close actual element
			CASE
				WHEN lead( level ) OVER( ORDER BY id ) < level THEN -- last children in group, close parents, until next level
				repeat( ']}', level - lead( level ) OVER( ORDER BY id ) ) || ',' 
				ELSE repeat( ']}', level ) -- last element in list, close parents all levels
			END
		END AS json_covers
	FROM tree
) s1 GROUP BY id_polygon, siose_code;


$literal$;

script:=format(script, quote_literal($1));

EXECUTE script INTO siose_object;
RETURN siose_object;

END
$BODY$ 
LANGUAGE plpgsql;
