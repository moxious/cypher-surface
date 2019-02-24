USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS 
FROM 'https://raw.githubusercontent.com/moxious/cypher-surface/master/neo4j-surface.csv'
as line

MERGE (neo4j:Neo4j { version: line.version })
MERGE (t:SurfaceElement {
    type: line.type,
    name: line.name
})
MERGE (sig:Signature { value: line.signature })
MERGE (d:Description { value: line.description })
MERGE (mode:Mode { value: line.mode })

MERGE (t)-[:IN]->(neo4j)
MERGE (t)-[:HAS]->(sig)
MERGE (t)-[:DESCRIBED_BY]->(d)
MERGE (t)-[:MODE]->(mode)
RETURN count(t);