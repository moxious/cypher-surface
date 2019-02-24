MATCH (n:Neo4j)
WHERE n.version =~ '.*enterprise'
SET n.edition = 'enterprise'
RETURN count(n);

MATCH (n:Neo4j)
WHERE NOT n.version =~ '.*enterprise'
SET n.edition = 'community'
RETURN count(n);

MATCH (s:Signature) 
WITH s, split(s.value, ') :: (') as parts
WITH s, parts[0] + ')' as element,
coalesce('(' + parts[1], 'VOID') as returnType

WITH 
   s, 
   element, 
   returnType,
   split(returnType, ', ') as returnParts

RETURN element, returnType, s.value;