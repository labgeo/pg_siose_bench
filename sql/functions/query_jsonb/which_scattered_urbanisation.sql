CREATE OR REPLACE FUNCTION siose.which_scattered_urbanisation()
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
	WHERE 
	docs @> '{"polygon": {"cover": {"-id": "UDS", "cover": [{"-id": "EDF"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "UDS", "cover": [{"-id": "EDF"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "UDS", "cover":[{"-id": "EDF"}]}]}]}}}'
  )

  SELECT id_polygon FROM bfilter;
  
  SELECT siose.log_query_plans('which_scattered_urbanisation');
$BODY$
  LANGUAGE sql VOLATILE;
