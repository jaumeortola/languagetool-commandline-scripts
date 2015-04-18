#!/bin/bash
/home/jaume/languagetool_work/copyfiles.sh
java -jar ~/lt/languagetool-commandline.jar -v -c utf-8 -u -b -l ca-ES text.txt
