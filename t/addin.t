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
#use is;
use t;
use Data::Dumper;
our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG=0;

if(defined $ARGV[0] and $ARGV[0] eq '-d'){
  $DEBUG=1;
}

# prepare test input files

my %indata;
my $mode="";
my $i=0;
$_=<DATA>;
while(<DATA>){
  if(/^---start mg(?:\s*(.*))?$/){
    $i++;
    my $x=$1;
    $mode='mg';
    $x=~s/[\n\r]*$//;
    $indata{tag}[$i]=$x;
    next;
  } 
  /^---start html/ and ($mode='html', next);
  /^---start log/  and ($mode='log', next);
  /^---end/ and last;
  $indata{$mode}[$i] .= $_;
}

prepare($indata{mg}, $indata{html});
#test_cmd("STDIN -> STDOUT",     {"<"=>"$indir/0.wini", ">"=>"$outdir/0.html"},                $outdir, ["$outdir/0.html"]);
  Text::Markup::Wini::init();
  my $newdir  = outdir4indir($Indir);
  my $newout = "$newdir/1.html";
  my $newlog = "$newdir/1.err.log";
  test_cmd($indata{tag}[1], {i=>"$Indir/1.mg", o=>$newout, '2>'=>$newlog}, $newdir, [$newout, $newlog], [$indata{html}[1], $indata{log}[1]]);
  (!$DEBUG) and remove_tree($newdir);



(!$DEBUG) and (-d $Indir)   and (print("remove $Indir\n"),   remove_tree($Indir));
(!$DEBUG) and (-d $Outdir)  and (print("remove $Outdir\n"),  remove_tree($Outdir));
#(!$DEBUG) and (-d $outdir2) and (print("remove $outdir2\n"), remove_tree($outdir2));
(!$DEBUG) and map {unlink $_} <err*.log>;
done_testing;

__DATA__
"
---start mg A: extra macro without add-in pm

{{copyright|xxx|2020|2022}}

---start html A:
<p>
\{\{copyright|xxx|2020|2022}}<!-- Cannot find Macro 'copyright' -->
</p>

---start log A:
infile:  wini_in_2r56/1.mg
cssfile: wini.css
outfile: wini_out_2r56_lHq1/1.html
File specification: OK
[31m[47m[31m[47mWarning[0m at line 1606. 1220[Text::Markup::Wini::call_macro]@Wini.pm <- 1057[Text::Markup::Wini::markgaab]@Wini.pm <- 507[Text::Markup::Wini::to_html]@Wini.pm <- 332[Text::Markup::Wini::stand_alone]@Wini.pm[0m
  Cannot find Macro 'copyright'

---start mg B: extra macro with add-in pm

{{copyright|xxx|2020|2022}}

---start html B:
<p>
&copy; 2020-2022, xxx, All rights reserved.</span> 
</p>

---end
