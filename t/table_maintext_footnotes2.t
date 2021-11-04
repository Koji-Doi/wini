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

|- capt.      | &c b@2                |
|!$        l3 |      e {{^|captE}}    |
|!$        l4 |&b    f {{^|captF|+}}  |
|!$        l5 |&b    f2{{^|captF2|+}} |
|!$        l6 |&b    e2{{^|captE2}}   |
|!$        l7 |&b    g {{^|captG|**}} |
|!$        l8 |&b    h {{^|captH|d}}  |
|!$        l9 |&b    i {{^|captI|**}} |
|--- inner table footnote             |

Main text with footnote{{^|main text footnote}}.
Main text with footnote{{^|main text footnote2|d}}.

|- capt2.     | &c b@2                |
|!$        l3 |      e {{^|captE}}    |
|!$        l4 |&b    f {{^|captF|+}}  |
|!$        l5 |&b    f2{{^|captF2|+}} |
|!$        l6 |&b    e2{{^|captE2}}   |
|!$        l7 |&b    g {{^|captG|**}} |
|!$        l8 |&b    h {{^|captH|d}}  |
|!$        l9 |&b    i {{^|captI|**}} |
|--- inner table footnote2            |

Main text with footnote{{^|main text footnote3}}.
Main text with footnote{{^|main text footnote4|d}}.

EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;
<p>
Table
</p>

<table id="winitable1" class="winitable" style="border-collapse: collapse;  text-align: center; ">
<caption> capt.</caption>
<tbody style="border:solid 2px;">
<tr><th  style="border:solid 2px; ">l3 </th><td  style="border:solid 2px; ">e <sup>&lowast;1</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l4 </th><td  style="border:solid 2px; vertical-align:bottom; ">f <sup>&plus;1</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l5 </th><td  style="border:solid 2px; vertical-align:bottom; ">f2<sup>&plus;2</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l6 </th><td  style="border:solid 2px; vertical-align:bottom; ">e2<sup>&lowast;2</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l7 </th><td  style="border:solid 2px; vertical-align:bottom; ">g <sup>&lowast;</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l8 </th><td  style="border:solid 2px; vertical-align:bottom; ">h <sup>&dagger;1</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l9 </th><td  style="border:solid 2px; vertical-align:bottom; ">i <sup>&lowast;&lowast;</sup> </td></tr>
</tbody>
<tfoot>
<tr><td colspan="2">inner table footnote; <sup>&lowast;1</sup>captE;
<sup>&plus;1</sup>captF;
<sup>&plus;2</sup>captF2;
<sup>&lowast;2</sup>captE2;
<sup>&lowast;</sup>captG;
<sup>&dagger;1</sup>captH;
<sup>&lowast;&lowast;</sup>captI</td></tr>
</tfoot>
</table>
<p>
Main text with footnote<sup>&lowast;1</sup>.
Main text with footnote<sup>&dagger;1</sup>.
</p>

<table id="winitable2" class="winitable" style="border-collapse: collapse;  text-align: center; ">
<caption> capt2.</caption>
<tbody style="border:solid 2px;">
<tr><th  style="border:solid 2px; ">l3 </th><td  style="border:solid 2px; ">e <sup>&lowast;1</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l4 </th><td  style="border:solid 2px; vertical-align:bottom; ">f <sup>&plus;1</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l5 </th><td  style="border:solid 2px; vertical-align:bottom; ">f2<sup>&plus;2</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l6 </th><td  style="border:solid 2px; vertical-align:bottom; ">e2<sup>&lowast;2</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l7 </th><td  style="border:solid 2px; vertical-align:bottom; ">g <sup>&lowast;</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l8 </th><td  style="border:solid 2px; vertical-align:bottom; ">h <sup>&dagger;1</sup> </td></tr>
<tr><th  style="border:solid 2px; ">l9 </th><td  style="border:solid 2px; vertical-align:bottom; ">i <sup>&lowast;&lowast;</sup> </td></tr>
</tbody>
<tfoot>
<tr><td colspan="2">inner table footnote2; <sup>&lowast;1</sup>captE;
<sup>&plus;1</sup>captF;
<sup>&plus;2</sup>captF2;
<sup>&lowast;2</sup>captE2;
<sup>&lowast;</sup>captG;
<sup>&dagger;1</sup>captH;
<sup>&lowast;&lowast;</sup>captI</td></tr>
</tfoot>
</table>
<p>
Main text with footnote<sup>&lowast;2</sup>.
Main text with footnote<sup>&dagger;2</sup>.
</p>

<hr>
<footer>
<ul style="list-style:none;">
<li><sup>&lowast;1</sup>main text footnote</li>
<li><sup>&dagger;1</sup>main text footnote2</li>
<li><sup>&lowast;2</sup>main text footnote3</li>
<li><sup>&dagger;2</sup>main text footnote4</li>
</ul>
</footer>

EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}
  
done_testing;

