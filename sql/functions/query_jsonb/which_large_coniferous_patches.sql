
CREATE OR REPLACE FUNCTION jsonb.which_large_coniferous_patches()
  RETURNS void AS
$BODY$


DECLARE
script text;

BEGIN

script:= $literal$


  PREPARE q(geometry) AS
  WITH polygons AS(
    SELECT id_polygon, docs
    FROM jsonb.docstore_jsonb
    WHERE geom && $1
  ),
  --Now unnest every possible inner level
  --Max. upper bound of parents array (zero based) equals 3 as per
  --SELECT MAX(array_length(id_parents,1)) FROM siose.siose_values
  --issued on the relational docker, which means a maximum of 4
  --nesting levels for any JSON document.
  bfilter AS(
    --No need to unnest level 0
    SELECT id_polygon, docs #> '{polygon,cover}' AS elements
    FROM polygons
    WHERE docs @> '{"polygon": {"cover": {"-id": "CNF"}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF"}]}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF"}]}]}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-id": "CNF"}]}]}]}}}'
  ),
  unnest1 AS(
    SELECT id_polygon, jsonb_array_elements(elements #> '{cover}') as elements FROM bfilter
  ),
  unnest2 AS(
    SELECT id_polygon, jsonb_array_elements(elements #> '{cover}') as elements FROM unnest1
  ),
  unnest3 AS(
    SELECT id_polygon, jsonb_array_elements(elements #> '{cover}') as elements FROM unnest2
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

  --A polygon may have many CNF covers over 1Ha, thus grouping is required.
  SELECT id_polygon
  FROM bind
  WHERE elements->>'-id'='CNF' AND (elements->>'-area_ha')::numeric > 1
  GROUP BY id_polygon;

  SELECT reports.log_query_plans('jsonb.which_large_coniferous_patches()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;
