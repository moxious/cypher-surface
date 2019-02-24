#!/bin/bash

for version in $(cat versions.txt) ; do
    ./mk-neo4j.sh $version ;
done