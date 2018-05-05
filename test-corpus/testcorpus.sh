#!/bin/bash

#export M2_HOME=/usr/local/apache-maven/apache-maven-3.2.2
#export M2=$M2_HOME/bin
#export PATH=/usr/local/apache-maven/apache-maven-3.2.2/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/bin

cd /home/ec2-user/test-corpus/

### Compilant amb Maven...
#cd /home/ec2-user/test-corpus/languagetool/
#git pull --rebase
#mvn package -DskipTests
#sudo cp -R /home/ec2-user/test-corpus/languagetool/languagetool-standalone/target/LanguageTool-2.9-SNAPSHOT/LanguageTool-2.9-SNAPSHOT/* /usr/share/lt/

corpusDir="/home/ec2-user/test-corpus/corpus/"
targetDir="/home/ec2-user/test-corpus/resultats-tests"


# Try to download most recent LT version
# Not used for now since it is running as a service
yesterday=`date -d "yesterday 13:00 " '+%Y%m%d'`
lt_file=LanguageTool-$yesterday-snapshot.zip
lt_url="https://languagetool.org/download/snapshots/$lt_file"
lt_path="/home/ec2-user/languagetool"
wget -q $lt_url
if [[ $? -eq 0 ]]; then
    echo downloaded $lt_url
    rm $lt_path/* -r -f
    #mkdir $lt_path
    #Skip the first directory on the zip file (e.g. /LanguageTool-3.0-SNAPSHOT)
    unzip -d "$lt_path" "$lt_file" && f=("$lt_path"/*) && mv "$lt_path"/*/* "$lt_path" && rmdir "${f[@]}"
    rm -f $lt_file
fi



# opció eliminada: -u (llista de paraules desconegudes)
commandOptions="-jar $lt_path/languagetool-commandline.jar -b -c utf-8 -l ca-ES --line-by-line"
date=`date +%Y%m%d`
mkdir $targetDir/$date

missatge="Tests fets!
"

#corpus_selecte iec01 ec01
#cmu-corpus
#bci cmu01 cmu02 corpus_selecte ec01 ec02 epubcat01 epubcat02 epubcat03 epubcat04 epubcat05 epubcat06 epubcat07 epubcat08 epubcat09 epubcat10 epubcat11 iec01 iec02 qg uv valencia

#for filepath in $corpusDir/*.txt
for filepath in $corpusDir/catorze.txt $corpusDir/corpus_selecte.txt $corpusDir/ec01.txt $corpusDir/iec01.txt
do
    file=$(basename "$filepath" .txt)
    echo "Analitzant arxiu: $file"
    if [ -f "$corpusDir/$file.txt" ];
    then
	cd $targetDir
	mv -f "${file}.new" "${file}.old"
	java $commandOptions "$corpusDir/$file.txt" | sed -e 's/[0-9]\+.) //' > ${file}.new
	sed -i -r 's/Line [0-9]+, column [0-9]+, //' ${file}.new
#	sed -i 's/^.*Unkown words:.+$//' ${file}.new
	diff -u ${file}.old ${file}.new >${file}.diff
	diffSize=$(wc -c <"${file}.diff")
	if [ $diffSize -lt 10 ]; then
	    echo "Fet. No hi ha diferències en: $file"
	    missatge+="$file (0): No hi ha diferències.
"
	elif [ $diffSize -gt 5000000 ]; then
	    echo "Fet. Hi ha diferències molt grans en: $file"
	    missatge+="$file ($diffSize): Diferències massa grans. No es mostren.
"
	else
	    resultFile="${file}_${date}.html"
	    vim ${file}.diff -c TOhtml -c ":saveas $resultFile" -c ":q" -c ":q" >>vim.log 2>>vim-error.log
	    sed -i -e 's/background-color: #ffffff;/background-color: #000000;/g' $resultFile
	    mv -f $resultFile "$targetDir/$date/"
	    echo "Fet. Hi ha diferències en: $file"
	    missatge+="$file ($diffSize): http://www.riuraueditors.cat/tests/$date/${resultFile}
"
	fi
    else
	echo "Arxiu de corpus inaccessible."
    fi
done

sudo cp -R "$targetDir/$date" /var/www/html/rr/tests/



sudo aws sns publish --topic-arn arn:aws:sns:us-west-2:030392386923:WebsTirant --message "$missatge" --subject "Tests LT"
echo "FET EN:"
date
#google-chrome $targetDir/$date

