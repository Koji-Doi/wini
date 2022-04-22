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
my %res;
($res{got}, $res{exp}) = ('', '');
my $r = decode('utf-8', `perl $infile 2>&1`);
($res{got}) = $r=~/got:\s*'(.*)'\n#\s*expected:/s;
($res{exp}) = $r=~/expected:\s*'(.*)/s;
$res{exp} =~ s/'.*//s;

foreach my $mode (qw/got exp/){
  open(my $fho, '>:utf8', "${mode}.html") or die;
  my @lines = grep {/./} split(/(<.*?>)/, $res{$mode});
  foreach my $l (@lines){
    chomp $l;
    print {$fho} "$l\n";
  }
  close $fho;
}
