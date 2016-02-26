
--Función genérica de lookups
CREATE OR REPLACE FUNCTION siose.table_lookup(attribute_codes integer[],tblname regclass, colid text, colname text) 
    RETURNS text[] AS $$
DECLARE
   curr_index integer:=0;
   curr_code integer;
   code_lookup text;

   result text[];
BEGIN
   FOREACH curr_code IN ARRAY COALESCE (attribute_codes,'{0}')
   LOOP
      curr_index:=curr_index+1;

      EXECUTE 'SELECT '|| quote_ident(colname) || ' FROM '|| tblname || ' WHERE ' || quote_ident(colid)||'='||curr_code INTO code_lookup;
      result[curr_index]:=code_lookup;

   END LOOP;
   RETURN result;
END 
$$ 
LANGUAGE plpgsql;
