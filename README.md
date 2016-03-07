# pg_siose_bench
A PostgreSQL extension with tools for benchmarking different SIOSE database configurations (pure relational, indexed, json, jsonb, xml, etc)

INSTALLATION
------------

Requirements: PostgreSQL 9.5+, postgis extension

In directory where you downloaded pg_siose_bench run

    make
    sudo make install

Now, you can use this extension's functions to setup and perform some experiments
```
/*
NEED TO START HERE!!!
All other steps depend on this one
Rename or drop columns, add indexes, comma separated text to arrays, etc
*/
SELECT siose.setup_relational();

-- Create a JSONB document store
SELECT siose.jsonb_setup();

/*
Build grids from geometries in the relational schema. 
You could replace 'siose.siose_polygons' by 'sioseb.docstore_jsonb' and get the same results.
However, you could use a diferent boundary (e.g. administrative region, ROI, etc).
*/
SELECT grids.build_regular_grids('siose.spain_boundary_100k', 'siose.siose_polygons');
SELECT reports.setup_log_query_plans();

-- Full relational experiment
SELECT siose.reclass_into_coniferous_density_groups();
SELECT siose.sum_area_of_coniferous_plantations();
SELECT siose.which_coniferous_patches();
SELECT siose.which_large_coniferous_patches();
SELECT siose.which_reforested_areas();
SELECT siose.which_scattered_urbanisation();

-- Full JSONB experiment
SELECT sioseb.reclass_into_coniferous_density_groups();
SELECT sioseb.sum_area_of_coniferous_plantations();
SELECT sioseb.which_coniferous_patches();
SELECT sioseb.which_large_coniferous_patches();
SELECT sioseb.which_reforested_areas();
SELECT sioseb.which_scattered_urbanisation();
```