#!/bin/bash

#Directories
tikajar=/usr/share/tika/tika-app-1.7.jar
#tohtml=/usr/share/tika/results-to-html.pl
tohtml=./results-to-html.pl
lt_jar=~/lt/languagetool-commandline.jar
#lt_jar=/usr/share/lt/languagetool-commandline.jar

mkdir -p plaintext
mkdir -p results

rm plaintext/*
rm results/*

#Opcions de revisió
langcode=ca-ES
disabledRules=""
enabledRules=""

#Universitat de València
if [ "$1" = "uvalencia" ] ; then
    langcode=ca-ES-valencia
    disabledRules="-d EXIGEIX_ACCENTUACIO_VALENCIANA"
    enabledRules="-e EXIGEIX_ACCENTUACIO_GENERAL,CA_UNPAIRED_QUESTION,GUIONET_GUIO,PUNTS_SUSPENSIUS,EXIGEIX_PLURALS_S,EVITA_FUTUR_OBLIGACIO,EVITA_DEMOSTRATIUS_EIXE"
fi

#Llibre per a impremta - català general
if [ "$1" = "llibregeneral" ] ; then
    langcode=ca-ES
    disabledRules="-d MORFOLOGIK_RULE_CA_ES"
    enabledRules="-e GUIONET_GUIO,PUNTS_SUSPENSIUS,CA_UNPAIRED_QUESTION,EXIGEIX_PLURALS_S,PER_PER_A_INFINITIU,PRIORITZAR_COMETES"
fi

#Llibre per a impremta - valencià
if [ "$1" = "llibrevalencia" ] ; then
    langcode=ca-ES-valencia
    disabledRules="-d MORFOLOGIK_RULE_CA_ES,EVITA_DEMOSTRATIUS_EIXE"
    enabledRules="-e GUIONET_GUIO,PUNTS_SUSPENSIUS,CA_UNPAIRED_QUESTION,PRIORITZAR_COMETES"
fi

#Memòries Softcatalà
if [ "$1" = "softcatala" ] ; then
    langcode=ca-ES
    disabledRules="-d MORFOLOGIK_RULE_CA_ES,WHITESPACE_RULE"
    enabledRules="-e EXIGEIX_PLURALS_S"
fi


lt_opt="-u -b -c utf-8 -l $langcode $disabledRules $enabledRules"

# Converteix a text pla

for file in original/*
do
    echo "Convertint... $file"
    fbname=$(basename "$file")
    java -jar $tikajar -t "original/${fbname}" > "plaintext/${fbname}-plain.txt"
done

# Analitza amb LanguatgeTool

for file in plaintext/*-plain.txt
do
    echo "Analitzant... $file"
    fbname=$(basename "$file" -plain.txt)
    java -jar $lt_jar $lt_opt --api "plaintext/${fbname}-plain.txt" > "results/${fbname}-results.txt"
done

# Ordena i classifica els resultats
exit

for file in results/*-results.txt
do
    echo "Arreglant resultats... $file"
    fbname=$(basename "$file" -results.txt)
    perl $tohtml < "results/${fbname}-results.txt" > "results/${fbname}-results.html"
    sed -i 's/\t/ /g' "results/${fbname}-results.html"
    rm "results/${fbname}-results.txt"
done
