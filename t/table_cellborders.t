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
Table

|- capt.     |    |
|!        l1 |       a1 |   b1 |
|!        l2 |&b~5]5 a2 |   b2 |
|!        l3 |       a3 |=2 b3 |
|!        l4 |&b[5_5 a4 |   b4 |
|!        l5 |&b     a5 |@4 b5 |

EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;
<p>
Table
</p>

<table id="winitable1" class="winitable" style="border-collapse: collapse; ">
<caption> capt.</caption>
<tbody>
<tr><th  style="">l1 </th><td  style="">a1 </td><td  style="">b1 </td></tr>
<tr><th  style="">l2 </th><td  style="border-right:solid 5px; border-top:solid 5px; vertical-align:bottom; ">a2 </td><td  style="">b2 </td></tr>
<tr><th  style="">l3 </th><td  style="">a3 </td><td  style="border-bottom:solid 2px; border-top:solid 2px; ">b3 </td></tr>
<tr><th  style="">l4 </th><td  style="border-bottom:solid 5px; border-left:solid 5px; vertical-align:bottom; ">a4 </td><td  style="">b4 </td></tr>
<tr><th  style="">l5 </th><td  style="vertical-align:bottom; ">a5 </td><td  style="border-bottom:solid 4px; border-left:solid 4px; border-right:solid 4px; border-top:solid 4px; ">b5 </td></tr>
</tbody>
</table>

EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}
  
done_testing;

