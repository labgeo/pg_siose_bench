
CREATE TABLE siose.spain_boundary_100k
(
  id_0 serial NOT NULL,
  geom geometry(MultiPolygon,4326),
  tipo_0101 character varying(2),
  etiqueta character varying(254),
  CONSTRAINT spain_boundary_100k_pkey PRIMARY KEY (id_0)
)
