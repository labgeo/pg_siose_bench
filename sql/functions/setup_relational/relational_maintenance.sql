--Vacuuming
VACUUM;

CLUSTER siose.siose_polygons USING siose_polygons_geom_idx;
CLUSTER siose.siose_values USING siose_values_id_polygon_idx;

ANALYZE;
