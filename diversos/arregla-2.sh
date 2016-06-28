#!/bin/bash
mkdir arreglats
rm -rf arreglats/*
for file in *.txt
do
    perl arregla-fitxer.pl < ${file} > arreglats/${file}
done

