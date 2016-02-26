
/* 
This script is used to compose 7 rectangular grids for simulating web map queries on the SIOSE 
database. Each grid cell represents a map window at a given scale, and considering a panoramic
monitor (16:9 aprox). As 4326 is the working SRID defined for the siose polygons, these grids
have been created by applying a generalization in the meters to degrees conversion (1 degree=111.11111Km).
*/

--TODO: This funcion is only valid for the relational docker.
--Tables containing siose polygons in each docker can be renamed or we can add a parameter
--to allow specifying table names.
CREATE OR REPLACE FUNCTION build_regular_grids()
  RETURNS VOID AS
$func$
BEGIN

EXECUTE format('

CREATE TABLE siose.spain_grid_1m_temp AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,4.59000459,2.61000261,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);

CREATE TABLE siose.spain_grid_500k_temp AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,2.295002295,1.305001305,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);

CREATE TABLE siose.spain_grid_200k_temp AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.918000918,0.522000522,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);

CREATE TABLE siose.spain_grid_100k_temp AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.459000459,0.261000261,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);

CREATE TABLE siose.spain_grid_50k_temp AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.2295002295,0.1305001305,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);

CREATE TABLE siose.spain_grid_25k_temp AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.1147501148,0.06525006525,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);

CREATE TABLE siose.spain_grid_10k_temp AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.0459000459,0.0261000261,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);


--Add unique gids
ALTER TABLE siose.spain_grid_1m_temp ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_500k_temp ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_200k_temp ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_100k_temp ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_50k_temp ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_25k_temp ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_10k_temp ADD COLUMN gid SERIAL PRIMARY KEY;

--Calc stats
CREATE TABLE siose.spain_grid_1m AS(
	SELECT g.gid, g.geom AS geom, COUNT(s.gid) AS polycount
	FROM siose.docstore_json s, siose.spain_grid_1m_temp g
	WHERE s.geom && g.geom
	GROUP BY g.gid
);

CREATE TABLE siose.spain_grid_500k AS(
	SELECT g.gid, g.geom AS geom, COUNT(s.gid) AS polycount
	FROM siose.docstore_json s, siose.spain_grid_500k_temp g
	WHERE s.geom && g.geom
	GROUP BY g.gid
);

CREATE TABLE siose.spain_grid_200k AS(
	SELECT g.gid, g.geom AS geom, COUNT(s.gid) AS polycount
	FROM siose.docstore_json s, siose.spain_grid_200k_temp g
	WHERE s.geom && g.geom
	GROUP BY g.gid
);

CREATE TABLE siose.spain_grid_100k AS(
	SELECT g.gid, g.geom AS geom, COUNT(s.gid) AS polycount
	FROM siose.docstore_json s, siose.spain_grid_100k_temp g
	WHERE s.geom && g.geom
	GROUP BY g.gid
);

CREATE TABLE siose.spain_grid_50k AS(
	SELECT g.gid, g.geom AS geom, COUNT(s.gid) AS polycount
	FROM siose.docstore_json s, siose.spain_grid_50k_temp g
	WHERE s.geom && g.geom
	GROUP BY g.gid
);

CREATE TABLE siose.spain_grid_25k AS(
	SELECT g.gid, g.geom AS geom, COUNT(s.gid) AS polycount
	FROM siose.docstore_json s, siose.spain_grid_25k_temp g
	WHERE s.geom && g.geom
	GROUP BY g.gid
);

CREATE TABLE siose.spain_grid_10k AS(
	SELECT g.gid, g.geom AS geom, COUNT(s.gid) AS polycount
	FROM siose.docstore_json s, siose.spain_grid_10k_temp g
	WHERE s.geom && g.geom
	GROUP BY g.gid
);


DROP TABLE siose.spain_grid_1m_temp;
DROP TABLE siose.spain_grid_500k_temp;
DROP TABLE siose.spain_grid_200k_temp;
DROP TABLE siose.spain_grid_100k_temp;
DROP TABLE siose.spain_grid_50k_temp;
DROP TABLE siose.spain_grid_25k_temp;
DROP TABLE siose.spain_grid_10k_temp;');--, add parameters here);

END
$func$ LANGUAGE plpgsql;


