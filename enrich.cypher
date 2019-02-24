MATCH (n:Neo4j)
WHERE n.version =~ '.*enterprise'
SET n.edition = 'enterprise'
RETURN count(n);

MATCH (n:Neo4j)
WHERE NOT n.version =~ '.*enterprise'
SET n.edition = 'community'
RETURN count(n);

/* Text processing on signatures in preparation */
WITH '\\((.*)\\)' as splitToksRegex
MATCH (s:Signature) 
WITH s, split(s.value, ') :: (') as parts, splitToksRegex
WITH s, parts[0] + ')' as element, splitToksRegex,
coalesce('(' + parts[1], 'VOID') as returnType

WITH 
   s, 
   element, 
   returnType,
   splitToksRegex,
   apoc.text.regexGroups(element, splitToksRegex)[0][1] as parameters
SET 
   s.returnTypes = split(returnType, ', '),
   s.parameters = split(parameters, ', ')
RETURN count(s);

/* Parameters */
MATCH (s:Signature)
WHERE s.parameters is not null
UNWIND s.parameters as parameter
WITH s, split(parameter, ' :: ') as parts
WITH s, parts[0] as paramName, coalesce(parts[1], 'NONE') as paramType
WITH s, split(paramName, ' = ') as parts, paramType
WITH s, parts[0] as paramName, coalesce(parts[1], 'NONE') as paramDefaultValue, paramType
MERGE (t:Type { name: paramType })
MERGE (p:Parameter { name: paramName, defaultValue: paramDefaultValue })
MERGE (p)-[:TYPE]->(t)
MERGE (p)-[:INPUT]->(s)
RETURN count(p);

/* Return values */
MATCH (s:Signature)
WHERE s.returnTypes is not null
UNWIND s.returnTypes as returnType
WITH s, split(returnType, ' :: ') as parts
WITH 
    s, 
    replace(replace(parts[0], '(', ''), ')', '') as name, 
    parts[1] as type, parts
WITH 
    s, 
    name, 
    replace(replace(coalesce(parts[1], name), '(', ''), ')', '') as type
MERGE (t:Type { name: type })
MERGE (o:Output { name: name })
MERGE (s)-[:PRODUCES]->(o)
MERGE (o)-[:TYPE]->(t)
RETURN count(o);