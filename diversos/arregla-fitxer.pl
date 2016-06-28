#!/bin/perl
my $previous ="";
while (my $line = <>) {
    $found=0;
    if ($previous =~ /^$/) {
	print "\n";
    } else {
	my $first = substr $line, 0, 1;
	if ($first eq lc $first) {
	    print $previous;
	} else {
	    print $previous."\n";
	}
    }
    chomp $line;
    if ($line =~ /[^ ]$/) {
	$line = $line." ";
    }

    $line =~ s/ ([:;,\.\)])/$1/g;
    $line =~ s/\b([DdLlSsTtMmNn]') /$1/g;
    $line =~ s/  / /g;
    $line =~ s/\( /(/g;
    $previous = $line;
}
print "$previous\n";
