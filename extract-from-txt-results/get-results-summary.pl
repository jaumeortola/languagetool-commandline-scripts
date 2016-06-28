#!/usr/bin/perl
use strict;
use warnings;
#use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my %rules = ();

while (my $line = <>) {
    chomp($line);
    if ($line =~ / Rule ID: ([^\[]+)/) {
	my $ruleID=$1;
	if (exists $rules{$1})	{
	    $rules{$1}++;
	}
	else {
	    $rules{$1}=1;
	}
    }
}

print "*************************\n";
print "Rules by number of errors\n";
print "*************************\n";
foreach (sort { ($rules{$b} <=> $rules{$a}) || ($a cmp $b) } keys %rules) 
{
    print "$rules{$_} errors: $_\n";
}



