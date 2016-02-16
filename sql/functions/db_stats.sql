
WITH sizes AS(
SELECT relname as "Table",
	pg_size_pretty(pg_total_relation_size(relid)) As "Size",
	pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "External Size"
FROM pg_catalog.pg_statio_user_tables 

WHERE schemaname='siose'
AND relname != 'spain_boundary_100k'
AND relname != 'query_plans'
),
nrows AS (
SELECT relname AS "Table",
	reltuples::double precision AS "#Rows"
FROM pg_class
WHERE relname != 'spain_boundary_100k'
AND relname != 'query_plans'
AND relname != 'spatial_ref_sys'
AND relkind = 'r'
AND relname NOT LIKE '%pg_%'
AND relname NOT LIKE '%sql_%'
)

SELECT s."Table", "#Rows", "Size", "External Size"
FROM sizes s 
JOIN nrows n ON s."Table"=n."Table"
ORDER BY n."#Rows" DESC

