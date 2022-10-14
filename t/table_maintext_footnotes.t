#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;
use lib './t';
use t;

our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;

{
  #  my($o, undef) = markgaab(<<'EOC');
  my $src = <<'EOC';
Table

|- capt.      | border="1"            |
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

EOC

  my $exp = <<EOC;
<p>
Table
</p>

<table class="mgtable" border="1" style="border-collapse: collapse; border: solid 1px;">
<caption>
capt.
</caption>
<tbody>
<tr><th>l3</th><td>e <sup>&lowast;1</sup></td></tr>
<tr><th>l4</th><td style="vertical-align:bottom;">f <sup>&plus;1</sup></td></tr>
<tr><th>l5</th><td style="vertical-align:bottom;">f2<sup>&plus;2</sup></td></tr>
<tr><th>l6</th><td style="vertical-align:bottom;">e2<sup>&lowast;2</sup></td></tr>
<tr><th>l7</th><td style="vertical-align:bottom;">g <sup>&lowast;</sup></td></tr>
<tr><th>l8</th><td style="vertical-align:bottom;">h <sup>&dagger;1</sup></td></tr>
<tr><th>l9</th><td style="vertical-align:bottom;">i <sup>&lowast;&lowast;</sup></td></tr>
</tbody>
<tfoot>
<tr><td colspan="2">inner table footnote; <br><sup>&lowast;1</sup>captE;&nbsp;
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

<hr>
<footer>
<ul style="list-style:none;">
<li><sup>&lowast;1</sup>main text footnote</li>
<li><sup>&dagger;1</sup>main text footnote2</li>
</ul>
</footer>

EOC

  test1('test1', $src, $exp);
}

done_testing;

