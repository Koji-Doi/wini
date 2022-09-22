#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use lib '.';
use lib './t';
use Wini;
use is;
use t;

our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG=0;

if(defined $ARGV[0] and $ARGV[0] eq '-d'){
  $DEBUG=1;
}
print STDERR "debug mode: $DEBUG.\n";

{
my $cnt=1;
sub test0{ # check only output file list
  my($testname, $cmd, $outdir, $out) = @_;
  print STDERR "\n[$cnt]--- $testname\n";
  my $r = system("perl Wini.pm $cmd");
  ($r>0) and $r = $r >> 8;
  if($r>0){
    print STDERR (<<"EOD");
    Error occured in trying '$cmd'.
    Return=$r
EOD
  }
  my $o = join("\n", <$outdir/*.html>, <$outdir/*.css>);
  is $o, $out, $testname;
  ($DEBUG) or map { unlink $_} <$outdir/*>;
  $cnt++;
}

sub test1{ # check output css and html files, in specifying indir/1.wini
  my($testname, $cmd, $indir, $outdir, $outfiles) = @_;
#  my $infile2  = $infile || "$indir/1.wini";
  my $outdir2  = $outdir || tempdir('wini_testout_XXXX');
  my $outfile2 = (defined $outfiles->[0]) ? $outfiles : ["$outdir2/1.html"]; 
  my $err="err${cnt}.log";
  $cmd=~s!\{\{indir}}!$indir!g;
  $cmd=~s!\{\{outdir}}!$outdir2!g;
  $cmd=~s!\{\{infile}}!${indir}/1.wini!g;
  $cmd=~s!\{\{outfile}}!${outdir2}/1.html!g;
  $cmd=~s!\{\{err}}!$err!g;

  print STDERR "\n[$cnt]--- $testname\n";
  ($DEBUG) and print STDERR "$cmd\n";
  my $r = system($cmd);
  ($r>0) and $r = $r >> 8;
  if($r>0){
    print STDERR (<<"EOD");
    Errror occured in trying '$cmd'.
    Return=$r
EOD
  }
  my $exp = join("\n", sort @$outfile2);
  my $got = join("\n", sort (<$outdir2/*.html>, <$outdir2/*.css>));
  $got=~s{${outdir2}/}{}sg;
  $got=~s/[\n\s]+/ /gs;
  is std($got), std($exp), $testname;
  $cnt++;
} # test1
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

test0("STDIN -> STDOUT"   , "<$indir/0.wini >$outdir/0.html 2>/dev/null",     $outdir, "$outdir/0.html");
test0("-i -> STDOUT"      , "-i $indir/0.wini > $outdir/0.html 2>/dev/null",  $outdir, "$outdir/0.html");
test0("STDIN -> -o"       , "-o $outdir/0.html < $indir/0.wini 2>/dev/null",  $outdir, "$outdir/0.html");
test0("-i... -> -o..."    , "-i $indir/0.wini -o $outdir/0.html 2>/dev/null", $outdir, "$outdir/0.html");
my $cmd = "-i $indir/0.wini -i $indir/1.wini -o $outdir/0.html 2>/dev/null";
test0("-i.f -i f -> -o f" , $cmd,                                             $outdir, "$outdir/0.html");
unlink "$outdir/0.html";

test_cmd('-i -i > -o d', {i=>["$indir/0.wini", "$indir/1.wini"], o=>$outdir}, $outdir, ["$outdir/0.wini.html","$outdir/1.wini.html"]);
#$cmd = "-i $indir/0.wini -i $indir/1.wini -o $outdir 2>/dev/null";
#test0("-i f -i f -> -o d" , $cmd,                                             $outdir, "$outdir/1.wini.html");

test_cmd('-i d -o f', {i=>$indir, o=>"$outdir/0.html"},                       $outdir, ["$outdir/0.html"], ['<p>0</p><p>1</p><p>2</p><p>3</p>']);
if(0){ # dir -> file
  my $outfile = "$outdir/0.html";
  system("perl Wini.pm -i $indir -o $outfile 2>/dev/null");
  my $o = join("\n", <$outdir/*>);
  open(my $fhi, '<:utf8', $outfile);
  $o .= join('', <$fhi>);
  close $fhi;
  $o=~s/[\n\s]//g;
  is $o, "$outdir/0.html<p>0</p><p>1</p><p>2</p><p>3</p>";
  map { unlink $_} <$outdir/*>;
}

{ # dir -> dir
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
$outdir = tempdir('wini_testout_XXXX');
test1('"dir -> dir": with -outcssfile',
  "perl Wini.pm --whole --outcssfile -i {{indir}} -o {{outdir}}/ 2>{{err}}",  $indir, $outdir,  $exp_outfiles);

map { unlink $_} <$outdir/*>;
test1('"file -> file in existing dir": with -outcssfile',
  "perl Wini.pm --whole --outcssfile -i {{infile}} -o {{outfile}} 2>{{err}}", $indir, $outdir, [qw/1.html 1.wini.css/]);

map { unlink $_} <$outdir/*>;
rmdir $outdir;
test1('"file -> file in non-existing dir": with -outcssfile',
  "perl Wini.pm --whole -outcssfile -i {{infile}} -o {{outfile}} 2>{{err}}",  $indir, undef, [qw/1.html 1.wini.css/]);

test1('"file -> dir in existing dir": with -outcssfile',
  "perl Wini.pm --whole --outcssfile -i {{infile}} -o {{outdir}}/ 2>{{err}}", $indir, $outdir, [qw/1.wini.html 1.wini.css/]);

map { unlink $_} <$outdir/*>;
rmdir $outdir;
test1('"file -> dir in non-existing dir": with -outcssfile',
  "perl Wini.pm --whole -outcssfile -i {{infile}} -o {{outdir}}/ 2>{{err}}",  $indir, undef, [qw/1.wini.html 1.wini.css/]);

(!$DEBUG) and (-d $indir)   and (print("remove $indir\n"),   remove_tree($indir));
(!$DEBUG) and (-d $outdir)  and (print("remove $outdir\n"),  remove_tree($outdir));
#(!$DEBUG) and (-d $outdir2) and (print("remove $outdir2\n"), remove_tree($outdir2));
(!$DEBUG) and map {unlink $_} <err*.log>;
done_testing;
