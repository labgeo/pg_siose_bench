
--TODO: Get #Rows from a COUNT(). 
--"reltuples" is just an approximation.
CREATE OR REPLACE FUNCTION reports.db_stats(_schemaname text)
RETURNS TABLE (
	"Table" text
	, "#Rows" double precision
	, "Size" text
	, "External Size" text) AS
$BODY$
BEGIN
   RETURN QUERY


WITH sizes AS(
SELECT relname::text as "Table",
	pg_size_pretty(pg_total_relation_size(relid)) As "Size",
	pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "External Size"
FROM pg_catalog.pg_statio_user_tables 

WHERE schemaname=_schemaname
),
nrows AS (
SELECT relname AS "Table",
	reltuples::double precision AS "#Rows"
FROM pg_class
)

SELECT s."Table", n."#Rows", s."Size", s."External Size"
FROM sizes s 
JOIN nrows n ON s."Table"=n."Table"
ORDER BY n."#Rows" DESC;


END
$BODY$  LANGUAGE plpgsql;