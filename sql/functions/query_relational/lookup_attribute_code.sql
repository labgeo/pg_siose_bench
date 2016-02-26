
CREATE OR REPLACE FUNCTION siose.lookup_attribute_code(attribute_codes integer[])
  RETURNS text[] AS
$BODY$
DECLARE
   curr_index integer:=0;
   curr_code integer;
   code_lookup text;
   result text[];
BEGIN
   FOREACH curr_code IN ARRAY COALESCE (attribute_codes,'{0}')
   LOOP
      curr_index := curr_index + 1;
      SELECT attribute_code FROM siose.siose_attributes WHERE id_attribute = curr_code INTO code_lookup;
      result[curr_index] := code_lookup;
   END LOOP;
   RETURN result;
END 
$BODY$
  LANGUAGE plpgsql VOLATILE