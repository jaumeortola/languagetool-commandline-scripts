#!/bin/perl
use utf8;
binmode( STDOUT, ":utf8" );


my $outputfilename = $ARGV[2];

my %words = ();
my %dict = ();
my @len = (0,0);

#read dictionary
my $ltdictfile ='/home/jaume/github/catalan-dict-tools/resultats/lt/diccionari.txt';
open( my $fh,  "<:encoding(UTF-8)", $ltdictfile );
while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /(.+) (.+) (.+)/) {
	if (!exists $dict{$1}) {
	    $dict{$1}=$2;
	    #print "$1 $2\n";
	}
    }
}
close( $fh );

for (my $i=0; $i<=1; $i++) {
    my $inputfilename = $ARGV[$i];
    open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
    while (my $line = <$fh>) {
	$len[$i]++;
	chomp $line;
	my @wordsinline = split(/[^₂²³a-zA-ZûêàéèíòóúïüäöîâÄÖÀÈÉÍÒÓÚÏÜÎÂçÇñÑå·0-9]/, $line);
	foreach my $w (@wordsinline) {
	    if (exists $dict{$w}) {
		$w = $dict{$w};
	    } elsif (exists $dict{lc $w}) {
		$w = $dict{lc $w};
	    } else {
		$w = lc $w."*";
	    }
	    if ($w =~ /.../ && $w !~ /^(prejudicis?|perjudicis?|sens|\d+\*?)$/) {
		if (exists $words{$w}) {
		    $words{$w}[$i]++;
		}
		else {
		    $words{$w}[$i]=2;
		    $words{$w}[($i+1)%2]=1;
		    $words{$w}[2]=0;
		    $words{$w}[3]=0;
		}
	    }
	}
    }
    close($fh);
}
print "$len[0] $len[1]\n";
foreach my $w (keys %words) {
    my $p0 = $words{$w}[0];
    my $p1 = $words{$w}[1]/$len[1]*$len[0];
    $words{$w}[2]=$p0/$p1;
    $words{$w}[3]=$p1/$p0;
}


open( my $ofh,  ">:encoding(UTF-8)", $outputfilename );
foreach (sort { ($words{$b}[2] <=> $words{$a}[2]) || ($a cmp $b) } keys %words) {
    my $w = $_;
    print $ofh "$w\t$words{$w}[0]\t$words{$w}[1]\t$words{$w}[2]\t$words{$w}[3]\n";
}
print $ofh "***********\n";
close($ofh);


my %words2 = ();
@len = (0,0);

for (my $i=0; $i<=1; $i++) {
    my $inputfilename = $ARGV[$i];
    open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
    while (my $line = <$fh>) {
#	print $line;
	$len[$i]++;
	chomp $line;
	my @wordsinline = split(/[^₂²³a-zA-ZûêàéèíòóúïüäöîâÄÖÀÈÉÍÒÓÚÏÜÎÂçÇñÑå·0-9]/, $line);
	my $ws="";
	my $tempmax = 0;
	foreach my $w (@wordsinline) {
	    if (exists $dict{$w}) {
		$w = $dict{$w};
	    } elsif (exists $dict{lc $w}) {
		$w = $dict{lc $w};
	    } else {
		$w = lc $w."*";
	    }
#	    if ($w =~ /./) {
#		print "$i $w $words{$w}[$i+2] $ws $tempmax\n";
#	    }
	    if (exists $words{$w} && $words{$w}[$i+2] > $tempmax) {
		$tempmax = $words{$w}[$i+2];
		$ws = $w;
	    }
	}
	if ($ws =~ /./) {
	    if (exists $words2{$ws}) {
		$words2{$ws}[$i]++;
	    }
	    else {
		$words2{$ws}[$i]=2;
		$words2{$ws}[($i+1)%2]=1;
		$words2{$ws}[2]=0;
		$words2{$ws}[3]=0;
	    }
	}

    }
    close($fh);
}

print "$len[0] $len[1]\n";
foreach my $w (keys %words2) {
    my $p0 = $words2{$w}[0];
    my $p1 = $words2{$w}[1]/$len[1]*$len[0];
    $words2{$w}[2]=$p0/$p1;
    $words2{$w}[3]=$p1/$p0;
}


open( my $ofh,  ">>:encoding(UTF-8)", $outputfilename );

foreach (sort { ($words2{$b}[2] <=> $words2{$a}[2]) || ($a cmp $b) } keys %words2) {
    my $w = $_;
    print $ofh "$w\t$words2{$w}[0]\t$words2{$w}[1]\t$words2{$w}[2]\t$words2{$w}[3]\n";
}

close($ofh);
