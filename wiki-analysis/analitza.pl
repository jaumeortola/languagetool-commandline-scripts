#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my $infilename   = "results.txt";
my $outfilename  = "analisi.txt";

open( my $fh,  "<:encoding(UTF-8)", $infilename );

my $title="";
my $matches=0;
my %articles = ();
my %articlesPerNombredErrors = ();
my %regles = ();

while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^Title: (.+)$/) {
	#recompte article anterior
	if (not exists $articlesPerNombredErrors{$matches}) {
	    $articlesPerNombredErrors{$matches}=1;
	} else {
	    $articlesPerNombredErrors{$matches}++;
	}
	#article nou
	$title=$1;
	$articles{$title}=0;
	$matches=0;
    }
    if ($line =~ / Rule ID: ([^\[]+)/) {
	my $ruleID=$1;
	if (exists $regles{$1})	{
	    $regles{$1}++;
	}
	else {
	    $regles{$1}=1;
	}
	if ($ruleID !~ /(UNPAIRED_BRACKETS|UPPERCASE_SENTENCE_START|WORD_REPEAT_RULE|COMMA_PARENTHESIS_WHITESPACE|WHITESPACE_RULE|WORD_REPEAT_BEGINNING_RULE|ESPAI_DESPRES_DE_PUNT|CA_UNPAIRED_BRACKETS|GUIONET_SOLT|EXIGEIX_VERBS_CENTRAL|EXIGEIX_ACCENTUACIO_GENERAL|EVITA_DEMOSTRATIUS_EIXE|PUNTS_SUSPENSIUS|EXIGEIX_POSSESSIUS_V)/) {
	    $articles{$title}++;
	    $matches++;
	}
    }
}
close ($fh);


open( my $ofh, ">:encoding(UTF-8)", $outfilename );

print $ofh "***************************************************\n";
print $ofh "Nombre d'articles per nombre d'errors per article\n";
print $ofh "***************************************************\n";
foreach (sort { $b <=> $a } keys %articlesPerNombredErrors) 
{
    print $ofh "Amb $_ errors: $articlesPerNombredErrors{$_} articles\n";
}

print $ofh "******************************\n";
print $ofh "Regles per nombre d'errors\n";
print $ofh "******************************\n";
foreach (sort { ($regles{$b} <=> $regles{$a}) || ($a cmp $b) } keys %regles) 
{
    print $ofh "Amb $regles{$_} errors: $_\n";
}

print $ofh "***************************************\n";
print $ofh "Articles ordenats per nombre d'errors\n";
print $ofh "***************************************\n";
foreach (sort { ($articles{$b} <=> $articles{$a}) || ($a cmp $b) } keys %articles) 
{
    print $ofh "$_: $articles{$_}\n";
}

close ($ofh);


