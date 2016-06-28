#!/bin/bash
#cat original/*.txt > tmp/all.txt
rm -rf tmp/*
rm -rf resultats/*
for i in $(seq 696)
do
    if [ -a "original/${i}.txt" ]; then
	iconv -f ISO-8859-15 -t UTF-8 original/${i}.txt > tmp/${i}.p1
	perl arregla-fitxer.pl < tmp/${i}.p1 > tmp/${i}.p2
	cp tmp/${i}.p2 resultats/${i}.txt
        echo "=== Fitxer font: ${i}.txt" >> resultats/all.txt
	cat tmp/${i}.p2 >> resultats/all.txt
    fi
done

