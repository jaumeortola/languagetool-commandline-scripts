@echo off

CLS

:: ***** DIRECTORIS *****
SET dir_principal=C:\Users\jaume\corrector\
SET dir_textoriginal=%dir_principal%text_original\
SET dir_textpla=%dir_principal%text_pla\
SET dir_resultats=%dir_principal%resultats\
SET jar_tika=%dir_principal%programes\tika-app-1.6.jar
SET jar_lt=%dir_principal%programes\languagetool\languagetool-commandline.jar
SET informe_html=%dir_principal%programes\results-to-html.pl

:: ***** CONFIGURACIÓ IEC *****
SET langcode=ca-ES
SET enabledRules=GUIONET_GUIO,PUNTS_SUSPENSIUS,EXIGEIX_PLURALS_S,COMETES_TIPOGRAFIQUES,APOSTROF_TIPOGRAFIC
SET disabledRules=MORFOLOGIK_RULE_CA_ES
SET lt_opt=-u -b -c utf-8 -l %langcode% -d %disabledRules% -e %enabledRules%
::ECHO %lt_opt%

:: **** NETEJA EL DIRECTORI DE TEXT PLA ****
cd %dir_textpla%
del */Q
cd %dir_principal%

:: ***** CONVERSIÓ A TEXT PLA *****
ECHO === Convertint a text pla ===
for %%i in (%dir_textoriginal%*) do (
  echo %%i ...
  java -Dfile.encoding=UTF-8 -jar %jar_tika% -t "%%i" > "%%i-textpla.txt"
)
move "%dir_textoriginal%*-textpla.txt" %dir_textpla%

:: ***** ANALISI *****
ECHO === Analitzant ===
for %%i in (%dir_textpla%*-textpla.txt) do (
  echo %%i ...
  java -Dfile.encoding=UTF-8 -jar %jar_lt% %lt_opt% "%%i" > "%%i-resultats.txt"
)
move "%dir_textpla%*-resultats.txt" %dir_resultats%

:: ***** INFORME FINAL *****
ECHO === Generant informe ===
for %%i in (%dir_resultats%*-resultats.txt) do (
  echo %%i ...
  perl %informe_html% "%%i"
)
del %dir_resultats%*-resultats.txt

:: ***** OBRE EL NAVEGADOR EN EL DIRECTORI DE RESULTATS *****
explorer %dir_resultats%
::start chrome %dir_resultats%
