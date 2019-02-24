#!/bin/bash
# Merge all of the outputted version-specific CSVs
# into one single overall CSV.
##################################################
OutFileName="neo4j-surface.csv"
i=0
for filename in ./*.csv; do 
 if [ "$filename"  != "$OutFileName" ] ;
 then 
   if [[ $i -eq 0 ]] ; then 
       # Copy header if it is the first file 
      head -1  "$filename" >   "$OutFileName"
   fi
   
   # Append from the 2nd line each file
   tail -n +2  "$filename" >>  "$OutFileName"
   i=$(( $i + 1 ))
 fi
done