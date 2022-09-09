#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use lib '.';
use Wini;
use is;

my $DEBUG=1;

sub std{
  my($x)=@_;
  $x=~s/[\n\r]/ /g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}/ /g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  $x=~s{(</\w+>)}{$1\n}g;
  return($x);
}

sub test1{
  my($testname, $cmd, $indir, $exp_outfiles) = @_;
  my $outdir2 = tempdir('wini_testout_XXXX');
  my $err="${outdir2}/err.log";
  $cmd=~s/\{\{indir}}/$indir/g;
  $cmd=~s/\{\{outdir}}/$outdir2/g;
  $cmd=~s/\{\{err}}/$err/g;

  ($DEBUG) and print STDERR "$cmd\n";
  system("$cmd 2>/dev/null");
#  my $i = join("\n", <$indir/*.wini>);
#  $i=~s/(\w+\.wini)/$1\.html $1\.css$1\.html\.ref/sg;
#  $i=~s{${indir}/}{}sg;
#  $i=~s/[\n\s]+/ /g;
  my $exp = join("\n", sort @$exp_outfiles);
  my $got = join("\n", sort (<$outdir2/*.html>, <$outdir2/*.css>));
  $got=~s{${outdir2}/}{}sg;
  $got=~s/[\n\s]+/ /gs;
  is std($got), std($exp), $testname;

  map { unlink $_} <$outdir2/*>;
  (!$DEBUG) and (-d $outdir2) and print("remove $outdir2\n"),remove_tree($outdir2);
  ($DEBUG)  and print STDERR "remained $indir, $outdir2\n";
}

my $indir  = tempdir('wini_in_XXXX');
my $outdir = tempdir('wini_out_XXXX');
#($indir, $outdir) = qw/wini_in wini_out/; #test
if(<$indir/*>){
  remove_tree($indir); mkdir $indir;
}
if(<$outdir/*>){
  remove_tree($outdir); mkdir $outdir;
}

# prepare test input files
my @infiles;
for my $x (0..3){
  my $infile = "$indir/$x.wini";
  push(@infiles, $infile);
  open(my $fho, '>', $infile) or die "cannot open $indir/$x.wini";
  print {$fho} "$x\n";
  close $fho;
}

{ #1 STDIN -> STDOUT
  system("perl Wini.pm <$indir/0.wini >$outdir/0.html 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  is $o, "$outdir/0.html", 'STDIN -> STDOUT';
  map { unlink $_} <$outdir/*>;
}

{ #2 -i -> STDOUT
  system("perl Wini.pm -i $indir/0.wini > $outdir/0.html 2>/dev/null");
  #print "$outdir/0.html ", ((-f "$outdir/0.html")?"exists":"missed"), "\n";
  my $o = join("\n", <$outdir/*>);
  is $o, "$outdir/0.html", '-i -> STDOUT';
  map { unlink $_} <$outdir/*>;
}

{ #3 STDIN -> -o...
  system("perl Wini.pm -o $outdir/0.html < $indir/0.wini 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  $o=~s/\s//gs;
  is $o, "$outdir/0.html", 'STDIN -> -o';
  map { unlink $_} <$outdir/*>;
}

{ #4 -i... -> -o...
  system("perl Wini.pm -i $indir/0.wini -o $outdir/0.html 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  $o=~s/\s//gs;
  is $o, "$outdir/0.html", '-i... -> -o...';
  map { unlink $_} <$outdir/*>;
}

{ #5 dir -> file
  my $outfile = "$outdir/0.html";
  system("perl Wini.pm -i $indir -o $outfile 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  open(my $fhi, '<:utf8', $outfile);
  $o .= join('', <$fhi>);
  close $fhi;
  $o=~s/[\n\s]//g;
  is $o, "$outdir/0.html<p>0</p><p>1</p><p>2</p><p>3</p>", 'dir -> file';
  map { unlink $_} <$outdir/*>;
}

{ #6 dir -> dir
  my $outdir2 = tempdir('wini_testout_XXXX');
  my $cmd = "perl Wini.pm -i $indir -o $outdir2/";
  ($DEBUG) and print STDERR "$cmd\n";
  system("$cmd 2>/dev/null");
  my $i = join("\n", <$indir/*.wini>);
  $i=~s/(\w+\.wini)/$1\.html $1\.html\.ref/sg;
  $i=~s{${indir}/}{}sg;
  $i=~s/[\n\s]+/ /g;
  my $o = join("\n", <$outdir2/*>);
  $o=~s{${outdir2}/}{}sg;
  $o=~s/[\n\s]+/ /gs;
  is $o, $i, 'dir -> dir';
  map { unlink $_} <$outdir2/*>;
  (-d $outdir2) and print("remove $outdir2\n"),remove_tree($outdir2);
}

my $exp_outfiles = [map {my $base = basename($_); ("$base.css", "$base.html")} @infiles];
test1('"dir -> dir": with -outcssfile', "perl Wini.pm -outcssfile -i {{indir}} -o {{outdir}}/ 2>{{err}}", $indir, $exp_outfiles);
=begin c

{ #6a dir -> dir (with -outcssfile)
  my $outdir2 = tempdir('wini_testout_XXXX');
  my $cmd = "perl Wini.pm -outcssfile -i $indir -o $outdir2/";
  ($DEBUG) and print STDERR "$cmd\n";
  system("$cmd 2>/dev/null");
  my $i = join("\n", <$indir/*.wini>);
  $i=~s/(\w+\.wini)/$1\.html $1\.html\.ref/sg;
  $i=~s{${indir}/}{}sg;
  $i=~s/[\n\s]+/ /g;
  my $o = join("\n", <$outdir2/*>);
  $o=~s{${outdir2}/}{}sg;
  $o=~s/[\n\s]+/ /gs;
  is $o, $i;
  map { unlink $_} <$outdir2/*>;
  (!$DEBUG) and (-d $outdir2) and print("remove $outdir2\n"),remove_tree($outdir2);
  ($DEBUG)  and print STDERR "remained $indir, $outdir, $outdir2\n";
}

=end c
=cut

(!$DEBUG) and (-d $indir)  and print("remove $indir\n"),  remove_tree($indir);
(!$DEBUG) and (-d $outdir) and print("remove $outdir\n"), remove_tree($outdir);
done_testing;
