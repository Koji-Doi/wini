#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use lib '.';
use wini;

# prepare test wini file
my @out;
my($parfile0, $tmplfile0) = ('templatetest.par', 'templatetest.wini');
my $filecnt=0;
l1: while(1){
  my $file = "no${filecnt}$tmplfile0";
  open(my $fho, '>', $file) or die "Failed to modify $file";
  while(<DATA>){
    (defined $_) or last l1;
    /<<<next>>>/ and last;
    print {$fho} $_;
  }
  close $fho;
  
  $file = "no${filecnt}$parfile0";
  open($fho, '>', $file) or die "Failed to modify $file";
  while(<DATA>){
    (defined $_) or last l1;
    s/<<<filecnt>>>/$filecnt/g;
    /<<<next>>>/ and last;
    print {$fho} $_;
  }
  close $fho;

  while(<DATA>){
    (defined $_) or last l1;
    /<<<end>>>/ and last l1;
    /<<<next>>>/ and last;
    chomp;
    $out[$filecnt] .= $_;
  }
  $filecnt++;
  ($filecnt>100) and die "Too many test files";
} # l1

# do test

for(my $i=0; $i<=$filecnt; $i++){
  my($parfile, $tmplfile) = ("no${i}$parfile0", "no${i}$tmplfile0");
  open(my $ph, '-|', "perl wini.pm -q -i $parfile") or die "Failed to excute perl";
  my $o = join('', <$ph>);
  $o=~s/[\n\r]*//g;
  is $o, $out[$i];
}

done_testing;

__DATA__
Var x from par file is [[x]], which should be 'abc'.
<<<next>>>
===
x: 'abc'
template: 'no<<<filecnt>>>templatetest.wini'
===
<<<next>>>
Var x from par file is abc, which should be 'abc'.
<<<next>>>
Var x from par file is [[x]], which should be 'abc'.

Main text which should be 'main text':
[[_]]

Section text which should be 'sect1text':
[[sect1]]

<<<next>>>
===
x: 'abc'
template: 'no<<<filecnt>>>templatetest.wini'
===

main text

? sect1
sect1text
<<<next>>>
Var x from par file is abc, which should be 'abc'.Main text which should be 'main text':<p>main text</p>Section text which should be 'sect1text':<p>sect1text</p>
<<<end>>>
  
