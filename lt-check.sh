#!/bin/bash

#Directories
tikajar=/usr/share/tika/tika-app-1.7.jar
#tohtml=/usr/share/tika/results-to-html.pl
tohtml=lt-results-to-html.py
lt_jar=~/target-lt/languagetool-commandline.jar
origin_dir=original
results_dir=results
#lt_jar=/usr/share/lt/languagetool-commandline.jar

mkdir -p results

#Opcions de revisió
langcode=ca-ES
disabledRules=""
enabledRules=""

analysis=1

if [ "$2" = "onlyconversion" ] ; then
    analysis=0
    echo "Only conversion to text!"
fi

#Universitat de València
if [ "$1" = "uvalencia" ] ; then
    langcode=ca-ES-valencia
    disabledRules="-d EXIGEIX_ACCENTUACIO_VALENCIANA"
    enabledRules="-e EXIGEIX_ACCENTUACIO_GENERAL,GUIONET_GUIO,PUNTS_SUSPENSIUS,EXIGEIX_PLURALS_S,EVITA_FUTUR_OBLIGACIO,EVITA_DEMOSTRATIUS_EIXE,EVITA_INTERROGACIO_INICIAL"
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
if [ "$1" = "levante" ] ; then
    langcode=ca-ES-valencia
    disabledRules="-d WHITESPACE_RULE"
    enabledRules="-e GUIONET_GUIO,PUNTS_SUSPENSIUS,CA_UNPAIRED_QUESTION,PRIORITZAR_COMETES"
fi
#Memòries Softcatalà
if [ "$1" = "softcatala" ] ; then
    langcode=ca-ES
    disabledRules="-d MORFOLOGIK_RULE_CA_ES,WHITESPACE_RULE,UPPERCASE_SENTENCE_START,CAMI_DE"
    enabledRules="-e EXIGEIX_PLURALS_S"
fi

#Test de poques regles
if [ "$1" = "test" ] ; then
    langcode=ca-ES
    disabledRules="-eo"
    enabledRules="-e CONFUSIONS_ACCENT"
fi


lt_opt="-u -b -c utf-8 -l $langcode $enabledRules $disabledRules --api"

for filename in $origin_dir/*
do
    fbname=$(basename "$filename")
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
    java -jar -Dfile.encoding=UTF-8 $tikajar -t "${filename}" > "${filename}-plain.txt"
    if [ "$analysis" = 1 ] ; then
	echo "Analitzant amb LanguageTool.. $filename"
	java -jar -Dfile.encoding=UTF-8 $lt_jar $lt_opt "${filename}-plain.txt" > "${filename}-lt.xml"
	echo "Arreglant resultats... $filename"
	python $tohtml -i "${filename}-lt.xml" -o $results_dir/"${fbname}body-lt.html"
	cat header.html $results_dir/"${fbname}body-lt.html" footer.html > $results_dir/"${fbname}-lt.html"
        rm "${filename}-plain.txt"
	rm $results_dir/"${fbname}body-lt.html"
	rm "${filename}-lt.xml"
    fi

done
