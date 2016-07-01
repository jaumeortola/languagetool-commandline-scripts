#!/usr/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
use POSIX qw(locale_h);
setlocale(LC_ALL, "C");
use Env qw(LANGUAGE_CODE);
my $languageCode = $LANGUAGE_CODE;


binmode( STDOUT, ":utf8" );

my $inputfilename = "$languageCode-dump-data/results.txt";
#my $outputfilename = "bot.txt";

open( my $fh,  "<:encoding(UTF-8)", $inputfilename );
#open( my $ofh,  ">:encoding(UTF-8)", $outputfilename );

open(my $listofrulesfile,  "<:encoding(UTF-8)", "rules-to-extract.txt" );
my $listofrules = join("",<$listofrulesfile>);
close $listofrulesfile;
$listofrules =~ s/ *\n/|/g;
$listofrules =~ s/\|$//;

my $regla=$ARGV[0];
my $outputfilename=$regla;
my $searchRuleID ="$regla";
if (not defined $regla) {
    $regla = $listofrules;
    $outputfilename="several";
    $searchRuleID ="($listofrules)";
}
print "Extracting rule(s): $regla\n";

my $inregla=0;
my $title="";
my $suggestion="";
my $original="";
my $context="";
my $liniesregla=0;
my $longitud=0;
my $longitudabans=0;
my $passatoriginal=0;
my $passatsuggestion=0;
my $linecount=0;
my $ruleID="";
my $discard=0;

my %clauordenacio= ();
my @original;
my @corregit;
my @accio;
my @titol;
my @errors;
my @suggeriments;
#my @discarded;

my $n=-1;

open(my $exceptionsfile,  "<:encoding(UTF-8)", "$languageCode/excepttitle.cfg" );
my $excepttitle = join("",<$exceptionsfile>);
close $exceptionsfile;
$excepttitle =~ s/ *\n/|/g;
$excepttitle =~ s/\|$//;


open( my $ofh2,  ">:encoding(UTF-8)", "sentences_$outputfilename.txt" );

while (my $line = <$fh>) {
    chomp($line);

    if ($line =~ /Rule ID: /) {
	if ($line =~ /Rule ID: $searchRuleID(\[\d+\])?$/) {
#	if ($line =~ /Rule ID: $regla\[[1-6]\]$/) {

	    #print $ofh2 "Title: $title\n";
	    $inregla=1;
            $ruleID="$regla$1";
            $discard=0;
            #print "$line\n";
            # ignore sentences with some percentage of errors
            if ($line =~ /ErrorsPerSentence: (.+)%/) {
		my $percent = $1;
		if ($percent>100) {
#		    $inregla=0;
                    $discard=1;
		}
	    }
	} else {
	    #&Eixida();
	    $inregla=0;
	    $liniesregla=0;
	}
    }

    if ($inregla && $title !~ /$excepttitle/) {
	$liniesregla++;
	#print $ofh2 "$line\n";

#	if ($passatsuggestion) {  #No és fix!!!¡
#	    $context=$line;
#	}

	if ($line =~ /^Suggestion: ([^;]+)/) {
#	if ($line =~ /^Suggestion: (.+)$/) {
	    $suggestion=$1;
	    #$suggestion="'";
	    $passatsuggestion=1;
	} else {
	    $passatsuggestion=0;
	}

	if ($passatoriginal) {  #No és fix!!!¡
	    $linecount=$linecount+1;
	}

	if ($linecount == 3) {
	    $context=$line;
            if ($discard) {
	    	print "$context\n";
	    }
	}
	if ($linecount == 4) {
	    $passatoriginal=0;
	    $longitud=length($original);
	    &Eixida();
	    $inregla=0;
	    $liniesregla=0;
            $linecount=0;
            $original="";
	    $suggestion="";
	}

	if ($line =~ /^Error: (.+)$/) {
	    $original=$1;
	    #$suggestion="'";
	    $passatoriginal=1;
            $linecount=0;
	}

#	if ($line =~ /^(\s*)([\^]+)/) {
#	    $longitud = length($2);
#	    $longitudabans = length($1);
#	    $original = $context;
#	    $original =~ s/^.{$longitudabans}(.{$longitud}).*$/$1/;

#	    $longitud=length($original);

#	    &Eixida();
#	    $inregla=0;
#	    $liniesregla=0;
#	    $suggestion="";
#	}
#        print "$liniesregla $line\n";
#	print "$linecount $title $context $original $suggestion\n";

    }
    if ($line =~ /^Title: (.+)$/) {
	$title=qq($1);
    }
    if ($line =~ /Checking article/) {
	#&Eixida();
	$inregla=0;
	$liniesregla=0;
    }
}



sub Eixida {
    if ($inregla) {
	my $substituit=0;

	#if ($suggestion =~ /^Aquesta$/) {
	#    $suggestion = "Està";
	#}
	#if ($suggestion =~ /^aquesta$/) {
	#    $suggestion = "està";
	#}

	## Prepara "formulari"
	if ($suggestion =~ /^$/) {
	    $suggestion = $original;
	}
	#if ($context =~ /^(.*)$original(.*)$/) {

	if ($original =~ /^\p{Lu}.*$/) {
	    $suggestion = ucfirst $suggestion;
	}
	my $l1=$longitudabans-5;
	my $l2=$longitudabans+5;
	$n=$n+1; #compta nova entrada
	push (@original, $context);
	push (@titol, $title);
	push (@errors, $original);
	push (@suggeriments, $suggestion);
        #if ($context =~ /^(.{$l1,$l2})\b$original\b(.*)$/) {
	#if ($context =~ /^(.{$l1,$l2})\b$original(.*)$/) {
	if ($context =~ /^(.*?)\b\Q$original\E\b(.*)$/ ) {
	#if ($context =~ /^(.*)$original(.*)$/) {

	    my $abans=$1;
	    my $despres=$2;
            #my $frasecorregida = $context;
	    my $frasecorregida = "$abans$suggestion$despres";


	    #my $motprevi=$abans;
	    #$motprevi =~ s/^.*\b([^\b].+)$/$1/;
	    #$clauordenacio{$n}="$motprevi$suggestion$despres";
	    #$clauordenacio{$n}="$despres";
	    #print "AAAA $clauordenacio{$n}\n";
	    #$clauordenacio{$n}="$suggestion$despres";
	    $clauordenacio{$n}="$discard $ruleID $suggestion$despres";
	    push (@corregit, $frasecorregida);
            if ($discard) {
		push (@accio, "d");
	    }
	    else { 
		push (@accio, "y");
	    }
	    $substituit=1;
	} 
#=pod
	else {

	    # Intenta fer la substitució de les apostrofacions
	    #print "$suggestion $original\n";
	    if ($suggestion =~ /^(((A|a|De|de|Per|per) )?[ldLD]['])(.+)$/) {
		my $sugg1=$1; my $sugg2=$4;
		$original =~ /(el|El|la|La|de|De|al|Al|del|Del|pel|Pel|DE|AL|EL|PEL|LA) +(.+)/;
		my $orig1=$1; my $orig2=$2;
		#print "$orig1 $orig2 $sugg1 $sugg2\n";
		#print "$context\n"; 
		    my $abans="";
		    my $entremig="";
		    my $despres="";
		if (defined $orig2 && $context =~ /^(.*)$orig1 *( |\[\[|''|'''|'' *\[\[|''' *\[\[|\[\[.+\||'' *\[\[.+\||''' *\[\[.+\|)[ ]*$orig2(.*)$/) {
		    $abans=$1;
		    $entremig=$2;
		    $despres=$3;
		    my $frasecorregida = "$abans$sugg1$entremig$sugg2$despres";
		    #$frasecorregida =~ s/^(.* [lLdD])''(.*)$/$1\{\{'\}\}'$2/g; ##plantilla apòstrof
		    #print "$frasecorregida\n";

		    #my $motprevi=$abans;
		    #$motprevi =~ s/^.*\b([^\b].+ )$/$1/;
		    #$clauordenacio{$n}="$motprevi$suggestion$despres";

		    $clauordenacio{$n}="$sugg1$sugg2$despres";
		    push (@corregit, $frasecorregida);
		    push (@accio, "y");
		    $substituit=1;
		}
	    }
	    elsif ($suggestion =~ /^(el|El|la|La|de|De) (.+)$/) {
		my $sugg1=$1; my $sugg2=$2;
		$original =~ /([LlDd]['’])(.+)/;
		my $orig1=$1; my $orig2=$2;
		#print "$orig1 $orig2 $sugg1 $sugg2\n";
		my $abans="";
		my $entremig="";
		my $despres="";
		if ($context =~ /^(.*)$orig1 *( |\[\[|''|'''|'' *\[\[|''' *\[\[|\[\[.+\||'' *\[\[.+\||''' *\[\[.+\|)[ ]*$orig2(.*)$/) {
		#if ($context =~ /^(.*)$orig1(\[\[|''|'''|\[\[.+\|)$orig2(.*)$/) {
		    $abans=$1;
		    $entremig=$2;
		    $despres=$3;
		    my $frasecorregida = "$abans$sugg1 $entremig$sugg2$despres";

		    #my $motprevi=$abans;
		    #$motprevi =~ s/^.*\b([^\b].+ )$/$1/;
		    #$clauordenacio{$n}="$motprevi$suggestion$despres";

		    $clauordenacio{$n}="$sugg1$sugg2$despres";
		    push (@corregit, $frasecorregida);
		    push (@accio, "y");
		    $substituit=1;
		}
	    }
	    # Intenta fer la substitució de les contraccions
	    elsif ($suggestion =~ /^(al|als|del|dels|cal|cals|Al|Als|Del|Dels|Cal|Cals)$/) {
		my $sugg1=$1; #my $sugg2=$2;
		my $orig1=""; my $orig2="";
		$original =~ /(a|A|de|De|ca|Ca|d'|D') (el|els|El|Els)/;
		$orig1=$1; $orig2=$2;
		#print "$orig1 $orig2 $sugg1 $sugg2\n";
		#print "$context\n"; 
		if ($context =~ /^(.*)$orig1 *( |\[\[|''|'''|'' *\[\[|''' *\[\[|\[\[.+\||'' *\[\[.+\||''' *\[\[.+\|)[ ]*$orig2(.*)$/) {
		    my $abans=$1;
		    my $entremig=$2;
		    my $despres=$3;
		    my $frasecorregida = "$abans$sugg1$entremig$despres";
		    #$frasecorregida =~ s/^(.* [lLdD])''(.*)$/$1\{\{'\}\}'$2/g;
		    #print "$frasecorregida\n";

		    #my $motprevi=$abans;
		    #$motprevi =~ s/^.*\b([^\b].+ )$/$1/;
		    #$clauordenacio{$n}="$motprevi$suggestion$despres";

		    $clauordenacio{$n}="$sugg1$despres";
		    push (@corregit, $frasecorregida);
		    push (@accio, "s_arreglat");
		    $substituit=1;
		}
	    }
	}
#=cut
	if (!$substituit)  {
            $clauordenacio{$n}="$discard $ruleID   NoTrobat: $original";
	    push (@corregit, $context);
	    push (@accio, "n");
	    #print $ofh2 "$context SuggerimentNoTrobat\n";
	}
	
    }
}

# EIXIDA
foreach my $num (sort {$clauordenacio{$a} cmp $clauordenacio{$b}} keys %clauordenacio) {
    print $ofh2 "$original[$num]<|>$titol[$num]<|>$errors[$num]<|>$suggeriments[$num]\n";
    print $ofh2 "$corregit[$num]<|>$accio[$num]\n\n";
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



