#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;

sub std{
  my($x)=@_;
  $x=~s/[\n\r]*//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}//g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  return($x);
}

{
  my($o, undef) = markgaab(<<'EOC');
Table

|- capt.     |    |
|!        l1 |       a1 |   b1 |
|!        l2 |&b~5]5 a2 |   b2 |
|!        l3 |       a3 |=2 b3 |
|!        l4 |&b[5_5 a4 |   b4 |
|!        l5 |&b     a5 |@4 b5 |

EOC
  $o=std($o);

  my $p = <<EOC;
<p>
Table</p>

<table id="winitable1" class="winitable" style="border-collapse: collapse; ">
<caption> capt.</caption>
<tbody>
<tr><th>l1 </th><td>a1 </td><td>b1 </td></tr>
<tr><th>l2 </th><td style="border-right:solid 5px; border-top:solid 5px; vertical-align:bottom;">a2 </td><td>b2 </td></tr>
<tr><th>l3 </th><td>a3 </td><td style="border-bottom:solid 2px; border-top:solid 2px;">b3 </td></tr>
<tr><th>l4 </th><td style="border-bottom:solid 5px; border-left:solid 5px; vertical-align:bottom;">a4 </td><td>b4 </td></tr>
<tr><th>l5 </th><td style="vertical-align:bottom;">a5 </td><td style="border-bottom:solid 4px; border-left:solid 4px; border-right:solid 4px; border-top:solid 4px;">b5 </td></tr>
</tbody>
</table>
EOC
  $p=std($p);

  is $o, $p;
}
  
done_testing;

