# pg_siose_bench
A PostgreSQL extension with tools for benchmarking different SIOSE database configurations (pure relational, indexed, json, jsonb, xml, etc)

INSTALLATION
------------

Requirements: PostgreSQL 9.5+, postgis extension

In directory where you downloaded pg_siose_bench run

    make
    sudo make install
    
SETUP
------------
NEED TO START HERE!!!
All other steps depend on this one
Rename or drop columns, add indexes, comma separated text to arrays, etc

    SELECT relational.setup_relational();

Now, use the create a JSONB document store

    SELECT relational.jsonb_setup();


Build grids from geometries in the relational schema. 
You could replace 'relational.siose_polygons' by 'jsonb.docstore_jsonb' and get the same results.
However, you could use a diferent boundary (e.g. administrative region, ROI, etc).

    SELECT grids.build_regular_grids('grids.spain_boundary_100k', 'relational.siose_polygons');
    
Add logging capabilities

    SELECT reports.setup_log_query_plans();

EXPERIMENTS
------------

Now, you can use several testing functions to perform some experiments. 

Run a complete relational experiment

    SELECT relational.reclass_into_coniferous_density_groups();
    SELECT relational.sum_area_of_coniferous_plantations();
    SELECT relational.which_coniferous_patches();
    SELECT relational.which_large_coniferous_patches();
    SELECT relational.which_reforested_areas();
    SELECT relational.which_scattered_urbanisation();

Run a complete jsonb experiment

    SELECT jsonb.reclass_into_coniferous_density_groups();
    SELECT jsonb.sum_area_of_coniferous_plantations();
    SELECT jsonb.which_coniferous_patches();
    SELECT jsonb.which_large_coniferous_patches();
    SELECT jsonb.which_reforested_areas();
    SELECT jsonb.which_scattered_urbanisation();
