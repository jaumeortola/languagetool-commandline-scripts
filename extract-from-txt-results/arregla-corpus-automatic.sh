#!/bin/bash
for file in ~/lt/corpus/*.txt
do
    fbname=$(basename "$file" .txt)
    perl arregla-canvis-automatics.pl $file ~/lt/corpus/arreglat/$fbname.txt
done
