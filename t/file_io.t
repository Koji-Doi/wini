#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use lib '.';
use wini;

my $indir  = tempdir('wini_inXXXX');
my $outdir = tempdir('wini_outXXXX');
#($indir, $outdir) = qw/wini_in wini_out/; #test
if(<$indir/*>){
  remove_tree($indir); mkdir $indir;
}
if(<$outdir/*>){
  remove_tree($outdir); mkdir $outdir;
}

# prepare test input files
for my $x (0..3){
  open(my $fho, '>', "$indir/$x.wini") or die "cannot open $indir/$x.wini";
  print {$fho} "$x\n";
  close $fho;
}

{ #1 STDIN -> STDOUT
  system("perl wini.pm <$indir/0.wini >$outdir/0.html 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  is $o, "$outdir/0.html";
  map { unlink $_} <$outdir/*>;
}

{ #2 -i -> STDOUT
  system("perl wini.pm -i $indir/0.wini > $outdir/0.html 2>/dev/null");
  print "$outdir/0.html ", ((-f "$outdir/0.html")?"exists":"missed"), "\n";
  my $o = join("\n", <$outdir/*>);
  is $o, "$outdir/0.html";
  map { unlink $_} <$outdir/*>;
}

{ #3 STDIN -> -o...
  system("perl wini.pm -o $outdir/0.html < $indir/0.wini 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  is $o, "$outdir/0.html";
  map { unlink $_} <$outdir/*>;
}

{ #4 -i... -> -o...
  system("perl wini.pm -i $indir/0.wini -o $outdir/0.html 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  is $o, "$outdir/0.html";
  map { unlink $_} <$outdir/*>;
}

{ #5 dir -> file
  my $outfile = "$outdir/0.html";
  system("perl wini.pm -i $indir -o $outfile 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  open(my $fhi, '<:utf8', $outfile);
  $o .= join('', <$fhi>);
  close $fhi;
  $o=~s/[\n\s]//g;
  is $o, "$outdir/0.html<p>0</p><p>1</p><p>2</p><p>3</p>";
  map { unlink $_} <$outdir/*>;
}

{ #6 dir -> dir
  my $cmd = "perl wini.pm -i $indir -o $outdir";
  print STDERR "$cmd\n";
  system("perl wini.pm -i $indir -o $outdir 2>/dev/null");
  my $i = join("\n", <$indir/*>);
  $i=~s/\.wini/\.html/sg;
  $i=~s{${indir}/}{}sg;
  $i=~s/[\n\s]//g;
  my $o = join("\n", <$outdir/*>);
  $o=~s{${outdir}/}{}sg;
  $o=~s/[\n\s]//g;
  print ">>i>>$i\n>>o>>$o\n";
  is $o, $i;
  map { unlink $_} <$outdir/*>;
}

(-d $indir)  and print("remove $indir\n"),remove_tree($indir);
(-d $outdir) and print("remove $outdir\n"),remove_tree($outdir);

done_testing;
