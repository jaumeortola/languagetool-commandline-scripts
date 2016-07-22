#!/bin/bash
for file in /media/jaume/WD2011/commoncrawl/*.txt
do
    fbname=$(basename "$file" .txt)
    perl arregla-canvis-automatics.pl $file /media/jaume/WD2011/commoncrawl/arreglat/$fbname.txt
done
