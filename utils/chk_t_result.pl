#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Encode qw/encode decode/;

no warnings;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
use warnings;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my $infile = $ARGV[0]; # "t/test.t"
my $res = `perl $infile 2>&1`;
$res = decode('utf-8', $res);
my($got, $expected) = ('', '');
foreach my $l (split(/\n/, $res)){
  $l=~s/^# //;
  if($l=~/^\s*got: / .. $l=~/^'$/){
    $l=~/^\s*got: / and next;
    $l=~/^'$/       and next;
    $got .= "$l\n";
  }
  if($l=~/^\s*expected: / .. $l=~/^'$/){
    $l=~/^\s*expected: / and next;
    $l=~/^'$/            and next;
    $expected .= "$l\n";
  }

}
my @got      = split(/(<.*?>)/, $got);
my @expected = split(/(<.*?>)/, $expected);

open(my $fho_g, '>:utf8', "got.html") or die;
open(my $fho_e, '>:utf8', "exp.html") or die;
for(my $i=0; $i<=$#got; $i++){
  my $g = $got[$i]      || '';
  my $e = $expected[$i] || '';
  my $r = ($g eq $e)?1:0;
# print "$i>>$r>> $g\t$e\n";
  print {$fho_g} $g;
  print {$fho_e} $e;
}
close $fho_g;
close $fho_e;


