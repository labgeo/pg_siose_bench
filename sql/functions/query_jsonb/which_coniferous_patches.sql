CREATE OR REPLACE FUNCTION siose.which_coniferous_patches()
  RETURNS void AS
$BODY$
  PREPARE q(geometry) AS

  WITH polygons AS(
	SELECT id_polygon, docs
	FROM siose.docstore_jsonb
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

  SELECT siose.log_query_plans('which_coniferous_patches');
$BODY$
  LANGUAGE sql VOLATILE;
