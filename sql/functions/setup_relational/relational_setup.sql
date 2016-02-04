

--TODO: non tested as a function
CREATE OR REPLACE FUNCTION siose.setup_relational()
  RETURNS VOID AS
$func$
BEGIN

EXECUTE format('

--Rename siose_attributes columns
ALTER TABLE siose.siose_attributes RENAME COLUMN "ID_ATRIBUTOS" TO id_attribute;
ALTER TABLE siose.siose_attributes RENAME COLUMN "DESCRIPCION_ATRIBUTOS" TO attribute_desc;
ALTER TABLE siose.siose_attributes RENAME COLUMN "CODE_ABREVIADO" TO attribute_code;
ALTER TABLE siose.siose_attributes RENAME COLUMN "CLASIFICACION" TO classification;

--Rename siose_coverages columns
ALTER TABLE siose.siose_coverages RENAME COLUMN "ID_COBERTURAS" TO id_cover;
ALTER TABLE siose.siose_coverages RENAME COLUMN "DESCRIPCION_COBERTURAS" TO cover_desc;
ALTER TABLE siose.siose_coverages RENAME COLUMN "CODE_ABREVIADO" TO cover_code;
ALTER TABLE siose.siose_coverages RENAME COLUMN "LISTA_ATRIBUTOS" TO attribute_list;
ALTER TABLE siose.siose_coverages RENAME COLUMN "LISTA_OBLIGATORIAS" TO mandatory_list;
ALTER TABLE siose.siose_coverages RENAME COLUMN "LISTA_OPCIONALES" TO optional_list;
ALTER TABLE siose.siose_coverages RENAME COLUMN "ID_COBERTURAS_PADRES" TO id_parent_cover;

--Drop useless columns and rename others on siose_polygons
ALTER TABLE siose.siose_polygons DROP COLUMN superf_ha RESTRICT;
ALTER TABLE siose.siose_polygons DROP COLUMN obser_c RESTRICT;
ALTER TABLE siose.siose_polygons DROP COLUMN obser_n RESTRICT;
ALTER TABLE siose.siose_polygons DROP COLUMN codblq RESTRICT;
ALTER TABLE siose.siose_polygons DROP COLUMN siose_xml RESTRICT;

ALTER TABLE siose.siose_polygons RENAME COLUMN ogc_fid TO gid;
ALTER TABLE siose.siose_polygons RENAME COLUMN wkb_geometry TO geom;

--Rename siose_values columns
ALTER TABLE siose.siose_values RENAME COLUMN "ID1" TO id;
ALTER TABLE siose.siose_values RENAME COLUMN "ID_POLYGON" TO id_polygon;
ALTER TABLE siose.siose_values RENAME COLUMN "ID_COBERTURAS" TO id_cover;
ALTER TABLE siose.siose_values RENAME COLUMN "ID_ANCESTROS" TO id_parents;
ALTER TABLE siose.siose_values RENAME COLUMN "INTER_ID" TO inter_id;
ALTER TABLE siose.siose_values RENAME COLUMN "INTER_ANCESTROS" TO inter_parents;
ALTER TABLE siose.siose_values RENAME COLUMN "ATRIBUTOS" TO attributes;
ALTER TABLE siose.siose_values RENAME COLUMN "SUPERF_HA" TO area_ha;
ALTER TABLE siose.siose_values RENAME COLUMN "SUPERF_POR" TO area_perc;

--Cast comma separated values to arrays
CREATE TABLE siose.siose_values_1 AS
SELECT id_polygon,
id_cover,
string_to_array(id_parents, ',')::integer[] AS id_parents,
inter_id,
string_to_array(inter_parents, ',')::integer[] AS inter_parents,
string_to_array(attributes, ',')::integer[] AS attributes,
area_ha,
area_perc
FROM siose.siose_values

--Replace siose_values by siose_values_1
DROP TABLE siose.siose_values;
ALTER TABLE siose.siose_values_1 RENAME TO siose_values;
ALTER TABLE siose.siose_values ADD COLUMN id serial;
ALTER TABLE siose.siose_values ADD PRIMARY KEY (id);');


END
$func$ LANGUAGE plpgsql;

