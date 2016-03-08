
CREATE OR REPLACE FUNCTION jsonb.which_reforested_areas()
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
  bfilter AS(
	SELECT id_polygon
	FROM polygons p
	WHERE docs @> '{"polygon": {"cover": {"attributes": [{"-id": "pc"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"attributes": [{"-id": "pc"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"attributes": [{"-id": "pc"}]}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"attributes": [{"-id": "pc"}]}]}]}]}}}'

	OR docs @> '{"polygon": {"cover": {"attributes": [{"-id": "pl"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"attributes": [{"-id": "pl"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"attributes": [{"-id": "pl"}]}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"attributes": [{"-id": "pl"}]}]}]}]}}}'
  )
  SELECT id_polygon FROM bfilter;
 
  SELECT reports.log_query_plans('jsonb.which_reforested_areas()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;
