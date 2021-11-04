#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib '/home/koji/perl';
use mysystem;
use lib '.';
use wini;


{
  my($o, undef) = WINI::wini_sects(<<'EOC');
* a
* b


EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;


 <ul class="winilist">
  <li>a</li>
  <li>b</li>
 </ul>


EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}


{
  my($o, undef) = WINI::wini_sects(<<'EOC');
# a
# b


EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;


 <ol class="winilist">
  <li>a</li>
  <li>b</li>
 </ol>


EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}


done_testing;
