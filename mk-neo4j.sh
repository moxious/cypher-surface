#!/bin/bash
# Quick script to start a community instance for testing.
docker stop neo4j-empty
docker rm neo4j-empty

if [ -z "$1" ] ; then
   echo "Call me with a neo4j version"
   exit 1
fi

VERSION=$1

PASSWORD=admin
CWD=`pwd`
NEO4J=neo4j:$VERSION

docker pull $NEO4J

if [ $? -ne 0 ] ; then 
    echo "Cannot pull docker container for $NEO4J"
    exit 1
fi

docker run -d --name neo4j-empty --rm \
	-p 127.0.0.1:7474:7474 \
        -p 127.0.0.1:7687:7687 \
        --env=NEO4J_dbms_memory_pagecache_size=1G \
        --env=NEO4J_dbms_memory_heap_initial__size=2G \
        --env=NEO4J_dbms_memory_heap_max__size=4G \
	--env NEO4J_AUTH=neo4j/admin \
        --env=NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
	-t $NEO4J

echo "Letting container come up..."
sleep 15

DATAFILE=surface-$VERSION.csv
ERRORS=surface-$VERSION.err

echo "Extracting surface for $NEO4J"
cat surface.cypher | \
        docker exec --interactive neo4j-empty \
        bin/cypher-shell -a localhost -u neo4j \
        -p admin --format plain | \
        # Clean up cypher shell formatting
        sed 's|", "|","|g' | \
        # Add a version first column
        sed 's|^|"'$VERSION'",|g' | \
        # Replace entire first header row
        sed '1 s|^.*$|"version","type","name","signature","description","mode"|' \
        > $DATAFILE 2>$ERRORS

echo "Done $VERSION"