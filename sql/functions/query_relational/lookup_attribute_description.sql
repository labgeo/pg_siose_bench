
CREATE OR REPLACE FUNCTION relational.lookup_attribute_description(attribute_codes integer[])
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
      SELECT attribute_desc FROM relational.siose_attributes WHERE id_attribute = curr_code INTO code_lookup;
      result[curr_index] := code_lookup;
   END LOOP;
   RETURN result;
END 
$BODY$
  LANGUAGE plpgsql VOLATILE;

