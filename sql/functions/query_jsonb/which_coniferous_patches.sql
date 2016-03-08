
CREATE OR REPLACE FUNCTION sioseb.which_coniferous_patches()
  RETURNS void AS
$BODY$


DECLARE
script text;

BEGIN

script:= $literal$


  PREPARE q(geometry) AS

  WITH polygons AS(
	SELECT id_polygon, docs
	FROM sioseb.docstore_jsonb
	WHERE geom && $1
  ),
  bfilter AS(
	SELECT id_polygon
	FROM polygons
	WHERE docs @> '{"polygon": {"cover": {"-id": "CNF"}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "CNF"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "CNF"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"cover":[{"-id": "CNF"}]}]}]}}}'
  )
  SELECT id_polygon FROM bfilter;

  SELECT reports.log_query_plans('jsonb.which_coniferous_patches()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;

