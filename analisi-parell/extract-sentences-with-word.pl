#!/bin/perl
use utf8;
binmode( STDOUT, ":utf8" );

my $inputfilename = $ARGV[0];
my $outputfilename = $ARGV[1];
my $word = $ARGV[2];

print "Extracting sentences with word $word\n";

open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
open( my $ofh,  ">:encoding(UTF-8)", $outputfilename );

my $sentence = "";

while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /([^.:!?]*\b($word)\b[^.:!?]*)/) {
	print $ofh "$1\n";
    }
}
close($fh);
close($ofh);
