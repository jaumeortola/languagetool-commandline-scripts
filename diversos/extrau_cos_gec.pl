open (FILEOUT, "> gec5.txt");
@files = <gec5/*.html>;
my $copia=0;
my $costext="";
my $num_articles=0;
my $title="";
my $text="";
my $num="";
my $liniesperarticle=0;

foreach(@files){
	$filename=$_;
	open (FILEIN, "< $filename");
	$copia=0;
	$num_articles++;
	$title="";
	$num="";
	$text="";
	$costext="";
		#if ($num_articles>10)
		#{	last; }
	while (my $line=<FILEIN>){
			
				
		if ( $line=~ /ndchec=\"([1234567890]+)\"/ ){
			$num=$1;
		}
		
	 if ( $line=~ /EncapSec\">(.+?)<\/div>/){
		$title=$1;
		}
	 if ( $line=~ /Nom transcrit[^>]+> ?([^<]+)</){
		$title=$1;
	 }
	 if ( $line=~ /txtcos_1\">(.+?)<\/div>/){
		$text=$1;
		#last;
	 }
	 if ( $line =~/\t<\/div>/)
	 {
	 	$copia=0;
	 }
	 if ($copia==1)
	 {
	 	$costext.=" ".$line;
	 }
	 if ( $line =~/<div class\=\"txtcos\">/)
	 {
	 	$copia=1;
	 }
	 
	 
	 
	}
	
	if ($title =~ /(.+)/) {
	   print FILEOUT "== $num\n$title.\n$text\n";
	   print FILEOUT "$costext\n";
  }
	close (FILEIN);
}
