#!/bin/perl
use utf8;
binmode( STDOUT, ":utf8" );

my $inputfilename = $ARGV[0];
my $outputfilename = $ARGV[1];

my %postags = ();
my %bigrams = ();
my %trigrams = ();

open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
open( my $ofh,  ">:encoding(UTF-8)", $outputfilename );

my $previous="";
my $prePrevious="";

while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /"V.[GSI]/ && $previous =~ /"SPS/) {
	print $ofh "$previous\n";
	print $ofh "$line\n";
    }

    $prePrevious=$previous;
    $previous=$line;

}



close($fh);
close($ofh);
