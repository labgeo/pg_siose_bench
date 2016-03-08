

CREATE OR REPLACE FUNCTION sioseb.sum_area_of_coniferous_plantations()
  RETURNS void AS
$BODY$

DECLARE
script text;

BEGIN

script:= $literal$


  PREPARE q(geometry) AS
  WITH polygons AS(
    SELECT docs
    FROM sioseb.docstore_jsonb
    WHERE geom && $1
  ),
  --Now unnest every possible inner level
  --Max. upper bound of parents array (zero based) equals 3 as per
  --SELECT MAX(array_length(id_parents,1)) FROM siose.siose_values
  --issued on the relational docker, which means a maximum of 4
  --nesting levels for any JSON document.
  bfilter AS(
    --No need to unnest level 0
    SELECT docs#>'{polygon,cover}' AS elements
    FROM polygons
    WHERE docs @> '{"polygon": {"cover": {"-id": "CNF", "attributes": [{"-id": "pl"}]}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF", "attributes": [{"-id": "pl"}]}]}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF","attributes": [{"-id": "pl"}]}]}]}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-id": "CNF", "attributes": [{"-id": "pl"}]}]}]}]}}}'
  ),
  unnest1 AS(
    SELECT jsonb_array_elements(elements#>'{cover}') as elements FROM bfilter
  ),
  unnest2 AS(
    SELECT jsonb_array_elements(elements#>'{cover}') as elements FROM unnest1
  ),
  unnest3 AS(
    SELECT jsonb_array_elements(elements#>'{cover}') as elements FROM unnest2
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
  WHERE elements->>'-id'='CNF';

  SELECT reports.log_query_plans('jsonb.sum_area_of_coniferous_plantations()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;

