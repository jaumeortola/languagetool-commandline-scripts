#!/bin/bash

#Directories
tikajar=/usr/share/tika/tika-app-1.7.jar
#tohtml=/usr/share/tika/results-to-html.pl
tohtml=../results-to-html.pl
lt_jar=~/lt/languagetool-commandline.jar
#lt_jar=/usr/share/lt/languagetool-commandline.jar

mkdir -p results

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

cd original
for filename in *
do
    if [ "${filename: -3}" == ".po" ]
    then
	echo "Filtrant fitxer .po ${filename}"
	msgattrib --no-obsolete --no-fuzzy --translated "${filename}" > "${filename}-filtrat.po"
	po2txt "${filename}-filtrat.po" > "${filename}.html"
	sed -i 's/[_&]//g' "${filename}.html"
	sed -i 's/\\[rtn]/ /g' "${filename}.html"
	rm "${filename}-filtrat.po"
	filename="${filename}.html"
    fi

    echo "Convertint a text pla... $filename"
    java -jar $tikajar -t "${filename}" > "${filename}-plain.txt"
    echo "Analitzant amb LanguageTool.. $filename"
    java -jar $lt_jar $lt_opt "${filename}-plain.txt" > "${filename}-lt.txt"
    echo "Arreglant resultats... $filename"
    perl $tohtml < "${filename}-lt.txt" > "../results/${filename}-lt.html"
    sed -i 's/\t/ /g' "../results/${filename}-lt.html"

    rm "${filename}-plain.txt"
    rm "${filename}-lt.txt"
done
rm *.po.html
cd .. 
