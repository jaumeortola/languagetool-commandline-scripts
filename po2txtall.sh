#!/bin/bash
for file in original/*.po
do
    msgattrib --no-obsolete --no-fuzzy --translated $file > $file-filtrat.po
    po2txt $file-filtrat.po > $file.html
    sed -i "s/_//g" $file.html
    rm $file-filtrat.po
    rm $file
done
