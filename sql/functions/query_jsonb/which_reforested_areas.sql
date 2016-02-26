CREATE OR REPLACE FUNCTION siose.which_reforested_areas()
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
 
  SELECT siose.log_query_plans('which_reforested_areas');
$BODY$
  LANGUAGE sql VOLATILE;
