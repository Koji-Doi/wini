#!/usr/bin/perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;
Text::Markup::Wini::init();

# prepare test wini file
my @out;
my @label;
my($parfile0, $tmplfile0) = ('templatetest.par', 'templatetest.wini');
my $filecnt=0;
l1: while(1){
  # template section
  my $file = "no${filecnt}$tmplfile0";
  open(my $fho, '>', $file) or die "Failed to modify $file";
  while(<DATA>){
    /<<<label (.*)>>>/ and ($label[$filecnt]=$1, next);
    (defined $_) or last l1;
    /<<<next>>>/ and last;
    print {$fho} $_;
  }
  close $fho;

  # parameter section
  $file = "no${filecnt}$parfile0";
  open($fho, '>', $file) or die "Failed to modify $file";
  while(<DATA>){
    /<<<label (.*)>>>/ and ($label[$filecnt]=$1, next);
    (defined $_) or last l1;
    s/<<<filecnt>>>/$filecnt/g;
    /<<<next>>>/ and last;
    print {$fho} $_;
  }
  close $fho;

  # result section
  while(<DATA>){
    (defined $_)       or  last l1;
    /<<<end>>>/        and last l1;
    /<<<next>>>/       and last;
    /<<<label (.*)>>>/ and ($label[$filecnt]=$1, next);
    chomp;
    $out[$filecnt] .= $_;
  }
  $filecnt++;
  ($filecnt>100) and die "Too many test files";
} # l1

# do test

for(my $i=0; $i<=$filecnt; $i++){
  my($parfile, $tmplfile) = ("no${i}$parfile0", "no${i}$tmplfile0");
  my $cmd = "perl Wini.pm -q -i $parfile";
  print STDERR "$label[$i]: $cmd\n";
  open(my $ph, '-|', $cmd) or die "Failed to excute perl";
  my $o = join('', <$ph>);
  $o=~s/[\n\r]*//g;
  is $o, $out[$i], $label[$i];
  close $ph;

  $cmd = "perl Wini.pm --whole -q -i $parfile";
  print STDERR "$label[$i]: $cmd\n";
  open($ph, '-|', $cmd) or die "Failed to excute perl";
  $o = join('', <$ph>);
  $o=~s/[\n\r]*//g;
  is $o, $out[$i], "$label[$i] (whole)";

#  unlink $parfile;
#  unlink $tmplfile;
}

done_testing;

__DATA__
<<<label simple replace>>>
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
  
