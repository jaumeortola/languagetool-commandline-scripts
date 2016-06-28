#!/bin/bash
COUNTER=1
maxsize=50000000
mkdir joined
rm -rf joined/*
for file in /media/jaume/U500G/epub-txt/*.txt
do
    echo "==== font: $file" >> joined/$COUNTER.txt
    cat "$file" >> joined/$COUNTER.txt
    actualsize=$(wc -c <"joined/$COUNTER.txt")
    if [ $actualsize -ge $maxsize ]; then
	COUNTER=$[$COUNTER +1]
    fi
done
