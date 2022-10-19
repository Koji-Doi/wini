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
test_cmd('-i d -o f', {i=>$indir, o=>"$outdir/0.html"},                       $outdir, ["$outdir/0.html"], ['<p>0</p><p>1</p><p>2</p><p>3</p>']);

#9
my $outdir2 = outdir4indir($indir);
test_cmd('dir -> dir', {i=>$indir, o=>"$outdir2/"},          $outdir2, [map{"$outdir2/$_.wini.html"}(0..3)]);

#10
$outdir = tempdir('wini_testout_XXXX');
my @outfiles = map {my $a = basename($_); ("$outdir/$a.css","$outdir/$a.html")} @infiles;
test_cmd('"dir -> dir": with -outcssfile', {whole=>undef, outcssfile=>undef, i=>$indir, o=>"$outdir/"}, $outdir, \@outfiles);

#11
map { unlink $_} <$outdir/*>;
test_cmd('"file -> file in existing dir": with -outcssfile',
          {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$outdir/1.html", '2>'=>'{{err}}'}, $outdir, ["$outdir/1.html", "$outdir/1.wini.css"]);

#12
my $newdir = tempdir("wini_out0_XXXX");
rmdir $newdir; 
test_cmd('"file -> file in non-existing dir": with -outcssfile',
         {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$newdir/1.html", '2>'=>'{{err}}'}, $newdir, []);

#13
$newdir = tempdir("wini_out_XXXX");
test_cmd('"file -> dir in existing dir": with -outcssfile',
         {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$newdir/", '2>'=>'{{err}}'}, $newdir, ["$newdir/1.wini.html", "$newdir/1.wini.css"]);

#14
$newdir = tempdir("wini_out0_XXXX");
rmdir $newdir; 
test_cmd('"file -> dir in non-existing dir": with -outcssfile',
         {whole=>undef, outcssfile=>undef, i=>"$indir/1.wini", o=>"$newdir/", '2>'=>'{{err}}'}, $newdir, ["$newdir/1.wini.html", "$newdir/1.wini.css"]);

=begin c

test2('"file -> dir in existing dir": with -outcssfile',
  "perl Wini.pm --whole --outcssfile -i {{infile}} -o {{outdir}}/ 2>{{err}}", $indir, $outdir, [qw/1.wini.html 1.wini.css/]);

map { unlink $_} <$outdir/*>;
rmdir $outdir;
my($outdir4) = test2('"file -> dir in non-existing dir": with -outcssfile',
  "perl Wini.pm --whole -outcssfile -i {{infile}} -o {{outdir}}/ 2>{{err}}",  $indir, undef, [qw/1.wini.html 1.wini.css/]);

=end c

=cut

(!$DEBUG) and (-d $indir)   and (print("remove $indir\n"),   remove_tree($indir));
(!$DEBUG) and (-d $outdir)  and (print("remove $outdir\n"),  remove_tree($outdir));
(!$DEBUG) and (-d $outdir2) and (print("remove $outdir2\n"), remove_tree($outdir2));
(!$DEBUG) and (-d $newdir)  and (print("remove $newdir\n"),  remove_tree($newdir));
(!$DEBUG) and map {unlink $_} <err*.log>;
done_testing;
