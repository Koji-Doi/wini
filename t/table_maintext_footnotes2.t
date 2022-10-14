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
  $o=std($o);

  my $p = <<EOC;
<p>
Table
</p>

<table class="mgtable" style="border-collapse: collapse;  text-align: center;">
<caption>
capt.
</caption>
<tbody style="box-shadow: 0 0 0 2px black;">
<tr><th>l3</th><td>e <sup>&lowast;1</sup></td></tr>
<tr><th>l4</th><td style="vertical-align:bottom;">f <sup>&plus;1</sup></td></tr>
<tr><th>l5</th><td style="vertical-align:bottom;">f2<sup>&plus;2</sup></td></tr>
<tr><th>l6</th><td style="vertical-align:bottom;">e2<sup>&lowast;2</sup></td></tr>
<tr><th>l7</th><td style="vertical-align:bottom;">g <sup>&lowast;</sup></td></tr>
<tr><th>l8</th><td style="vertical-align:bottom;">h <sup>&dagger;1</sup></td></tr>
<tr><th>l9</th><td style="vertical-align:bottom;">i <sup>&lowast;&lowast;</sup></td></tr>
</tbody>
<tfoot>
<tr><td colspan="2">inner table footnote<br><sup>&lowast;1</sup>captE;&nbsp;
<sup>&plus;1</sup>captF;&nbsp;
<sup>&plus;2</sup>captF2;&nbsp;
<sup>&lowast;2</sup>captE2;&nbsp;
<sup>&lowast;</sup>captG;&nbsp;
<sup>&dagger;1</sup>captH;&nbsp;
<sup>&lowast;&lowast;</sup>captI</td></tr>
</tfoot>
</table><p>
Main text with footnote<sup>&lowast;1</sup>.
Main text with footnote<sup>&dagger;1</sup>.
</p>

<table class="mgtable" style="border-collapse: collapse;  text-align: center;">
<caption>
capt2.
</caption>
<tbody style="box-shadow: 0 0 0 2px black;">
<tr><th>l3</th><td>e <sup>&lowast;1</sup></td></tr>
<tr><th>l4</th><td style="vertical-align:bottom;">f <sup>&plus;1</sup></td></tr>
<tr><th>l5</th><td style="vertical-align:bottom;">f2<sup>&plus;2</sup></td></tr>
<tr><th>l6</th><td style="vertical-align:bottom;">e2<sup>&lowast;2</sup></td></tr>
<tr><th>l7</th><td style="vertical-align:bottom;">g <sup>&lowast;</sup></td></tr>
<tr><th>l8</th><td style="vertical-align:bottom;">h <sup>&dagger;1</sup></td></tr>
<tr><th>l9</th><td style="vertical-align:bottom;">i <sup>&lowast;&lowast;</sup></td></tr>
</tbody>
<tfoot>
<tr><td colspan="2">inner table footnote2<br><sup>&lowast;1</sup>captE;&nbsp;
<sup>&plus;1</sup>captF;&nbsp;<sup>&plus;2</sup>captF2;&nbsp;
<sup>&lowast;2</sup>captE2;&nbsp;
<sup>&lowast;</sup>captG;&nbsp;
<sup>&dagger;1</sup>captH;&nbsp;
<sup>&lowast;&lowast;</sup>captI</td></tr>
</tfoot>
</table><p>
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
  $p=std($p);

  is $o, $p;
}
  
done_testing;

