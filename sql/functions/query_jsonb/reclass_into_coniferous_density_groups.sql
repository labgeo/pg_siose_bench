

CREATE OR REPLACE FUNCTION jsonb.reclass_into_coniferous_density_groups()
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
  --SELECT MAX(array_length(id_parents,1)) FROM relational.siose_values
  --issued on the relational docker, which means a maximum of 4
  --nesting levels for any JSON document.
  bfilter AS(
    --No need to unnest level 0
    SELECT id_polygon, docs#>'{polygon,cover}' AS elements
    FROM polygons
    WHERE docs @> '{"polygon": {"cover": {"-id": "CNF"}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF"}]}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF"}]}]}}}'
    OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-id": "CNF"}]}]}]}}}'
  ),
  unnest1 AS(
    SELECT id_polygon, jsonb_array_elements(elements#>'{cover}') as elements FROM bfilter
  ),
  unnest2 AS(
    SELECT id_polygon, jsonb_array_elements(elements#>'{cover}') as elements FROM unnest1
  ),
  unnest3 AS(
    SELECT id_polygon, jsonb_array_elements(elements#>'{cover}') as elements FROM unnest2
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

  SELECT reports.log_query_plans('jsonb.reclass_into_coniferous_density_groups()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;

