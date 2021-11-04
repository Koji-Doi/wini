#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib '/home/koji/perl';
use mysystem;
use lib '.';
use wini;

{
  my($o, undef) = WINI::wini(<<'EOC');
|- table with &r and &&&l | border="1" |
|!!&&&l aaaaaaaaa | bbbbbbbbbb | cccccccc |
|&r   d |&&r&&&c&l e | f |
|     g |&r h | i |
| jjjjjjjjjjjjjjjjjjjjjjjjjjjj | kkkkkkkkkkkkkkkkkkkkkkkkkk | lllllllllllllllllllllllllll |


EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;

<table id="winitable1" class="winitable" border="1" style="border-collapse: collapse; border: solid 1px; ">
<caption> table with &r and &&&l</caption>
<tbody>
<tr><th  style="text-align:left; ">aaaaaaaaa </th><th  style="text-align:center; ">bbbbbbbbbb </th><th  style="">cccccccc </th></tr>
<tr style="text-align:right;"><td  style="text-align:right; ">d </td><td  style="text-align:left; ">e </td><td  style="">f </td></tr>
<tr><td  style="text-align:left; ">g </td><td  style="text-align:right; ">h </td><td  style="">i </td></tr>
<tr><td  style="text-align:left; ">jjjjjjjjjjjjjjjjjjjjjjjjjjjj </td><td  style="text-align:center; ">kkkkkkkkkkkkkkkkkkkkkkkkkk </td><td  style="">lllllllllllllllllllllllllll </td></tr>
</tbody>
</table>

EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}
  
done_testing;

