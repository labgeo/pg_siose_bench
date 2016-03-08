
CREATE OR REPLACE FUNCTION jsonb.which_scattered_urbanisation()
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
	FROM polygons
	WHERE 
	docs @> '{"polygon": {"cover": {"-id": "UDS", "cover": [{"-id": "EDF"}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"-id": "UDS", "cover": [{"-id": "EDF"}]}]}}}'
	OR docs @> '{"polygon": {"cover": {"cover": [{"cover": [{"-id": "UDS", "cover":[{"-id": "EDF"}]}]}]}}}'
  )

  SELECT id_polygon FROM bfilter;
  
  SELECT reports.log_query_plans('jsonb.which_scattered_urbanisation()');
$literal$;


EXECUTE script;

END
$BODY$ LANGUAGE plpgsql;
