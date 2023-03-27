#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Temp qw(tempdir tempfile);
use File::Path qw(remove_tree);
use lib '.';
use lib './t';
use Wini;
use t;

our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;

my $indir  = tempdir('wini_in_XXXX');
my $outdir = tempdir('wini_out_XXXX');

# prepare test input files
my @infiles;
for my $x (0..3){
  my $infile = "$indir/$x.wini";
  push(@infiles, $infile);
  open(my $fho, '>', $infile) or die "cannot open $indir/$x.wini";
  print {$fho} "$x\n";
  close $fho;
}

test_cmd("STDIN -> STDOUT",     {"<"=>"$indir/0.wini", ">"=>"$outdir/0.html"},                $outdir, ["$outdir/0.html"]);
test_cmd("-i -> STDOUT",        {i=>["$indir/0.wini"], '>'=>"$outdir/0.html"},                $outdir, ["$outdir/0.html"]);
test_cmd("STDIN -> -o",         {o=>"$outdir/0.html", '<'=>"$indir/0.wini"},                  $outdir, ["$outdir/0.html"]);
test_cmd("-i... -> -o...",      {i=>["$indir/0.wini"], o=>"$outdir/0.html"},                  $outdir, ["$outdir/0.html"]);
test_cmd("i-.f -i f -> -o f 2", {i=>["$indir/0.wini", "$indir/1.wini"], o=>"$outdir/0.html"}, $outdir, ["$outdir/0.html"]);
map {unlink $_} <$outdir/*>;

#6
test_cmd('-i -i > -o d', {i=>["$indir/0.wini", "$indir/1.wini"], o=>$outdir}, $outdir, ["$outdir/0.wini.html","$outdir/1.wini.html"]);
map {unlink $_} <$outdir/*>;

#7,8
test_cmd('-i d -o f', {i=>$indir, o=>"$outdir/00.html"},                       $outdir, ["$outdir/00.html"], ['<p>0</p><p>1</p><p>2</p><p>3</p>']);
map {unlink $_} <$outdir/*>;

#9
my $outdir2 = outdir4indir($indir);
test_cmd('dir -> dir', {i=>$indir, o=>"$outdir2/"},          $outdir2, [map{"$outdir2/$_.wini.html"}(0..3)]);

#10
my $outdir3 = tempdir('wini_testout_XXXX');
my @outfiles = map {my $a = basename($_); ("$outdir3/$a.css","$outdir3/$a.html")} @infiles;
test_cmd('"dir -> dir": with -outcssfile', {whole=>undef, outcssfile=>undef, i=>$indir, o=>"$outdir3/"}, $outdir3, \@outfiles);

#11
map { unlink $_} <$outdir3/*>;
test_cmd('"file -> file in existing dir": with -outcssfile',
          {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$outdir3/1.html", '2>'=>'{{err}}'}, $outdir3, ["$outdir3/1.html", "$outdir3/1.wini.css"]);

#12
my $newdir = tempdir("wini_out0_XXXX");
remove_tree $newdir; 
test_cmd('"file -> file in non-existing dir": with -outcssfile',
         {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$newdir/1.html", '2>'=>'{{err}}'}, $newdir, []);

#13
$newdir = tempdir("wini_out_XXXXXX");
test_cmd('"file -> dir in existing dir": with -outcssfile',
         {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$newdir/", '2>'=>'{{err}}'}, $newdir, ["$newdir/1.wini.html", "$newdir/1.wini.css"]);
remove_tree $newdir;

#14
$newdir = tempdir("wini_out0_XXXX");
rmdir $newdir; 
test_cmd('"file -> dir in non-existing dir": with -outcssfile',
         {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$newdir/", '2>'=>'{{err}}'}, $newdir, ["$newdir/1.wini.html", "$newdir/1.wini.css"]);
remove_tree $newdir;

#15
{
  my $i=0;
  remove_tree($indir);
  mkdir($indir);
  for my $d ("$indir/x", "$indir/y", "$indir/x/z"){
    mkdir($d);
    open(my $fho, '>', "$d/f$i.mg");
    print "$d/f$i.mg\n";
    print {$fho} "$i\n";
    $i++;
  }

  test_cmd('dir -> dir in non-existing dir',
         {whole=>undef, i=>$indir, o=>"$newdir/"}, $newdir, ["$newdir/x/f0.mg.html", "$newdir/y/f1.mg.html", "$newdir/x/z/f2.mg.html"]);

}

=begin c

test2('"file -> dir in existing dir": with -outcssfile',
  "perl Wini.pm --whole --outcssfile -i {{infile}} -o {{outdir}}/ 2>{{err}}", $indir, $outdir, [qw/1.wini.html 1.wini.css/]);

map { unlink $_} <$outdir/*>;
rmdir $outdir;
my($outdir4) = test2('"file -> dir in non-existing dir": with -outcssfile',
  "perl Wini.pm --whole -outcssfile -i {{infile}} -o {{outdir}}/ 2>{{err}}",  $indir, undef, [qw/1.wini.html 1.wini.css/]);

=end c

=cut

unless($DEBUG){
  foreach my $d ($indir, $outdir, $outdir2, $outdir2, $outdir3, $newdir){
    (-d $d) and remove_tree($d);
  }
  map {unlink $_} <err*.log>;
}
done_testing;
