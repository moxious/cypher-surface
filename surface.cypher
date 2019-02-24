CALL dbms.functions()
YIELD name, signature, description
return 'function' as type, name, signature, description, '' as mode
UNION 
CALL dbms.procedures()
YIELD name, signature, description, mode
RETURN 'procedure' as type, name, signature, description, mode
ORDER BY name, type, mode;
