#!/bin/perl
use utf8;
binmode( STDOUT, ":utf8" );


my $outputfilename = $ARGV[2];

my %words0 = ();
my %words1 = ();



my $inputfilename = $ARGV[0];
open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
while (my $line = <$fh>) {
    chomp $line;
    my @wordsinline = split(/[^₂²³a-zA-ZûêàéèíòóúïüäöîâÄÖÀÈÉÍÒÓÚÏÜÎÂçÇñÑå·0-9]/, $line);
    foreach my $w (@wordsinline) {
	if ($w =~ /./) {
	    if (exists $words0{$w}) {
		$words0{$w}++;
	    }
	    else {
		$words0{$w}=1;
	    }
	}
    }
}
close($fh);

$inputfilename = $ARGV[1];
open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
while (my $line = <$fh>) {
    chomp $line;
    my @wordsinline = split(/[^₂²³a-zA-ZûêàéèíòóúïüäöîâÄÖÀÈÉÍÒÓÚÏÜÎÂçÇñÑå·0-9]/, $line);
    foreach my $w (@wordsinline) {
	if ($w =~ /./) {
	    if (exists $words1{$w}) {
		$words1{$w}++;
	    }
	    else {
		$words1{$w}=1;
	    }
	}
    }
}
close($fh);


my $len0 = keys %words0;
my $len1 = keys %words1;
print "$len0 $len1\n";

open( my $ofh,  ">:encoding(UTF-8)", $outputfilename );

foreach (sort { ($words0{$b} <=> $words0{$a}) || ($a cmp $b) } keys %words0) 
{
    my $wo = $_;
    if (!exists $words1{$wo}) {
	print $ofh "$wo / $words0{$wo} -- 0\n";   
    } elsif ($words0{$wo}/$len0 > $words1{$wo}*10/$len1) { #$words1{$wo} < 5) {
	print $ofh "$wo / $words0{$wo} (".$words0{$wo}/$len0.") -- $words1{$wo} (".$words1{$wo}*10/$len1.")\n";   
    }
}

print $ofh "**********************\n";
foreach (sort { ($words1{$b} <=> $words1{$a}) || ($a cmp $b) } keys %words1) 
{
    my $wo = $_;
    if (!exists $words0{$wo}) {
	print $ofh "$wo  / $words1{$wo} -- 0\n";   
    } elsif ($words1{$wo}/$len1 > $words0{$wo}*10/$len0) { #($words0{$wo} < 5) {
	print $ofh "$wo / $words1{$wo} (".$words1{$wo}/$len1.") -- $words0{$wo} (".$words0{$wo}*10/$len0.")\n";   
    }

}



close($ofh);
