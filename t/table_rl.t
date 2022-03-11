#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;

{
  my($o, undef) = markgaab(<<'EOC');
|- table with &r and &&&l | border="1" |
|!!&&&l aaaaaaaaa | bbbbbbbbbb | cccccccc |
|&r   d |&&r&&&c&l e | f |
|     g |&r h | i |
| jjjjjjjjjjjjjjjjjjjjjjjjjjjj | kkkkkkkkkkkkkkkkkkkkkkkkkk | lllllllllllllllllllllllllll |


EOC
  $o=~s/[\n\r]*//g;
  $o=~s/\s{2,}/ /g;
  my $p = <<EOC;
<table class="mgtable" border="1" style="border-collapse: collapse; border: solid 1px; ">
<caption> table with &r and &&&l</caption>
<tbody>
<tr><th style="text-align:left;">aaaaaaaaa </th><th style="text-align:center;">bbbbbbbbbb </th><th>cccccccc </th></tr>
<tr style="text-align:right;"><td style="text-align:right;">d </td><td style="text-align:left;">e </td><td>f </td></tr>
<tr><td style="text-align:left;">g </td><td style="text-align:right;">h </td><td>i </td></tr>
<tr><td style="text-align:left;">jjjjjjjjjjjjjjjjjjjjjjjjjjjj </td><td style="text-align:center;">kkkkkkkkkkkkkkkkkkkkkkkkkk </td><td>lllllllllllllllllllllllllll </td></tr>
</tbody>
</table>
EOC
  $p=~s/[\n\r]*//g;
  $p=~s/\s{2,}/ /g;
  $o=~s{> *(\w+) *<}{">$1<"}ge;
  $p=~s{> *(\w+) *<}{">$1<"}ge;
  is $o, $p;
}
  
done_testing;

