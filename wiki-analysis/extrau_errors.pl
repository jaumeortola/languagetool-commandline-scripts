
#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my $inputfilename = "results.txt";
#my $outputfilename = "bot.txt";

open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
#open( my $ofh,  ">:encoding(UTF-8)", $outputfilename );

my $regla=$ARGV[0];
my $inregla=0;
my $title="";
my $suggestion="";
my $original="";
my $context="";
my $liniesregla=0;
my $longitud=0;
my $longitudabans=0;
my $passatoriginal=0;

open( my $ofh2,  ">:encoding(UTF-8)", "regla_$regla.txt" );

while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /Rule ID: /) {
	if ($line =~ /Rule ID: \Q$regla\E(\[\d+\])?$/) {
#	if ($line =~ /Rule ID: $regla\[2\]$/) {
	    print $ofh2 "Title: $title\n";
	    $inregla=1;
	} else {
	    #&Eixida();
	    $inregla=0;
	    $liniesregla=0;
	}
    }

    if ($inregla) {
	$liniesregla++;
	print $ofh2 "$line\n";
	if ($line =~ /^Suggestion: ([^;]+)/) {
	#if ($line =~ /^Suggestion: (.+)$/) {
	    $suggestion=$1;
	    #$suggestion="'";
	}
	if ($passatoriginal) {  #No és fix!!!¡
	    $context=$line;
	}

	if ($line =~ /^Original: (.+)$/) {
	    $original=$1;
	    #$suggestion="'";
	    $passatoriginal=1;
	} else {
	    $passatoriginal=0;
	}

	if ($line =~ /^(\s+)([\^]+)/) {
	    #$longitud=length($2);
	    $longitudabans=length($1);
	    $longitud=length($original);
	    &Eixida();
	    $inregla=0;
	    $liniesregla=0;
	    $suggestion="";
	}
    }
    if ($line =~ /^Title: (.+)$/) {
	$title=$1;
    }
    if ($line =~ /Checking article/) {
	#&Eixida();
	$inregla=0;
	$liniesregla=0;
    }
}

sub Eixida {
    if ($inregla) {
	## Prepara "formulari"
	if ($suggestion =~ /^$/) {
	    $suggestion = $original;
	}
	#if ($context =~ /^(.*)$original(.*)$/) {
	my $l1=$longitudabans-12;
	my $l2=$longitudabans+12;
        if ($context =~ /^(.{$l1,$l2})\b$original\b(.*)$/) {
	    my $abans=$1;
	    my $despres=$2;
	    print $ofh2 "$abans$suggestion$despres\n";
	} else {
	    print $ofh2 "$context SuggerimentNoTrobat\n";
	}
	print $ofh2 "ACCIÓ ([s]í, [n]o, [f]alsa alarma): s\n\n";
	
    }
}

close ($fh);
#close ($ofh);
close ($ofh2);

=mod
	my $longabans=$longitudabans-5;
	#if ($context =~ /(.{5})$original(.{5})/) {
	    #my $abans=$1;
            #my $original=$2;
	    #my $despres=$3;
	    #print $ofh "$title|$abans|$original|$despres|$suggestion\n";
	#}


	    my $mira=$abans.$original.$despres;
	    if ($mira =~ /( [lmnsdtLMNSDT][`´][Hh]?[aeiouàáèéìíòóùúAEIOUÀÁÈÉÌÍÒÓÙÚ]|[`´][sln][ ,;.])/) {
		print $ofh2 "ACCIÓ ([s]í, [n]o, [f]alsa alarma): s\n\n";
	    }
	    elsif ($mira =~ /([\d\(\s\-ã][`´]|[`´]\-)/) { 
		print $ofh2 "ACCIÓ ([s]í, [n]o, [f]alsa alarma): n\n\n";
	    }
	    else {
		print $ofh2 "ACCIÓ ([s]í, [n]o, [f]alsa alarma): revisa f\n\n";
	    }
=cut
