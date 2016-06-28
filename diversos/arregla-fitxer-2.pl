#!/bin/perl
my $previous ="";
my $in=1;
while (my $line = <>) {
    if ($line =~ /no (modifiqueu|modificar) (aquests estils|estos estilos)/) {
	if ($in) {
	    $in=0;
	} else {
	    $in=1;
	}
	next;
    }

    if ($line =~ /\{.*(break|white|decoration|webkit|space|white|margin|right|left|justify|size|align|style|height|weight|display|width|color|family|indent|always).*\}/) {
	next;
    }

    if ($in) {
	print STDERR "1 $line";
	my $search="\\/media\\/jaume\\/U500G\\/epub-txt\\/";
	$line = s/\Q$search\E//g;
	print STDERR "2 $line\n";
	print $line;
    }
}

