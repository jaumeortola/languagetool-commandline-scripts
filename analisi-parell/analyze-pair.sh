#/bin/bash
#corpus=~/lt/corpus
corpus=/media/jaume/WD2011/commoncrawl
grep -E "\b$1\b" $corpus/ca.*.txt > paragraphs_$1.txt
grep -E "\b$2\b" $corpus/ca.*.txt > paragraphs_$2.txt

perl -CA extract-sentences-with-word.pl paragraphs_$1.txt sentences_$1.txt $1
perl -CA extract-sentences-with-word.pl paragraphs_$2.txt sentences_$2.txt $2

perl -CA extract-words.pl sentences_$1.txt sentences_$2.txt results_$1_$2.txt

cp sentences_$1.txt sentences_error_$1.txt
cp sentences_$2.txt sentences_error_$2.txt

sed -i -r 's/\bbe\b\/bé/g' sentences_error_$1.txt
sed -i -r 's/\bbé\b\/be/g' sentences_error_$2.txt

cat sentences_$1.txt sentences_$2.txt > sentences_$1_$2.txt
cat sentences_error_$1.txt sentences_error_$2.txt > sentences_error_$1_$2.txt
