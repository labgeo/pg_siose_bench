
/* 
This script is used to compose 7 rectangular grids for simulating web map queries on the SIOSE 
database. Each grid cell represents a map window at a given scale, and considering a panoramic
monitor (16:9 aprox). As 4326 is the working SRID defined for the siose polygons, these grids
have been created by applying a generalization in the meters to degrees conversion (1 degree=111.11111Km).
*/

--TODO: test as a function
CREATE OR REPLACE FUNCTION build_regular_grids()
  RETURNS VOID AS
$func$
BEGIN

EXECUTE format('

CREATE TABLE siose.spain_grid_1m AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,4.59000459,2.61000261,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);


CREATE TABLE siose.spain_grid_500k AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,2.295002295,1.305001305,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);


CREATE TABLE siose.spain_grid_200k AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.918000918,0.522000522,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);


CREATE TABLE siose.spain_grid_100k AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.459000459,0.261000261,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);


CREATE TABLE siose.spain_grid_50k AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.2295002295,0.1305001305,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);


CREATE TABLE siose.spain_grid_25k AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.1147501148,0.06525006525,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);

CREATE TABLE siose.spain_grid_10k AS(

	SELECT (grid).geom
	FROM
	(SELECT siose.regular_grid(geom,0.0459000459,0.0261000261,FALSE) AS grid
	FROM siose.spain_boundary_100k) AS fishnet, siose.spain_boundary_100k AS spain
	WHERE st_intersects((grid).geom, spain.geom)
);



ALTER TABLE siose.spain_grid_1m ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_500k ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_200k ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_100k ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_50k ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_25k ADD COLUMN gid SERIAL PRIMARY KEY;
ALTER TABLE siose.spain_grid_10k ADD COLUMN gid SERIAL PRIMARY KEY;');--, add parameters here);

END
$func$ LANGUAGE plpgsql;
