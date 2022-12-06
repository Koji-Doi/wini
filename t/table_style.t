#!/usr/bin/env perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;

use lib '.';
use Wini;
use lib './t';
use t;
our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;

Text::Markup::Wini::init();

our %REF;
my %indata;
my $i=0;
my $mode="";
$_=<DATA>;
while(<DATA>){
  if(/^---start mg(?:\s*(.*))?$/){
    $i++;
    my $x=$1;
    $mode='mg';
    $x=~s/[\n\r]*$//;
    $indata{tag}[$i]=$x;
    next;
  }
  /^---start html/ and ($mode='html', next);
  /^---end/ and last;
  $indata{$mode}[$i] .= $_;
}

for(my $i=1; $i<=$#{$indata{mg}}; $i++){
  test1($indata{tag}[$i], $indata{mg}[$i], $indata{html}[$i]);
}

done_testing;

__DATA__
"

---start mg T1 no border line

|- no border line | |
| a | b | c |
| d | e | f |
| g | h | i |

---start html T1
<table class="mgtable" style="border-collapse: collapse; "><caption>no border line</caption>
 <tbody>
 <tr>
  <td>a</td>
  <td>b</td>
  <td>c</td>
 </tr>
 <tr>
  <td>d</td>
  <td>e</td>
  <td>f</td>
 </tr>
 <tr>
  <td>g</td>
  <td>h</td>
  <td>i</td>
 </tr>
 </tbody>
</table>

---start mg T2 outer frame

|- outer frame | @1 |
| a | b | c |
| d | e | f |
| g | h | i |

---start html T2
<table class="mgtable" style="border-collapse: collapse; border-left: solid 1px; border-right: solid 1px; border-bottom: solid 1px; border-top: solid 1px; "><caption>outer frame</caption>
 <tbody>
  <tr><td>a</td>
   <td>b</td>
   <td>c</td>
  </tr>
  <tr>
   <td>d</td>
   <td>e</td>
   <td>f</td>
  </tr>
  <tr>
   <td>g</td>
   <td>h</td>
   <td>i</td>
  </tr>
 </tbody>
</table>

---start mg T3 inner frame of tbody

|- inner frame of tbody | @@1 |
| a | b | c |
| d | e | f |
| g | h | i |

---start html T3

<table class="mgtable" style="border-collapse: collapse; "><caption>inner frame of tbody</caption>
 <tbody>
  <tr>
   <td style="border:solid 1px;">a</td>
   <td style="border:solid 1px;">b</td>
   <td style="border:solid 1px;">c</td>
  </tr>
  <tr>
   <td style="border:solid 1px;">d</td>
   <td style="border:solid 1px;">e</td>
   <td style="border:solid 1px;">f</td>
  </tr>
  <tr>
   <td style="border:solid 1px;">g</td>
   <td style="border:solid 1px;">h</td>
   <td style="border:solid 1px;">i</td>
  </tr>
 </tbody>
</table>

---start mg T3a inner frame of tbody

|- inner frame of tbody | @@1red |
| a | b | c |
| d | e | f |
| g | h | i |

---start html T3a
<table class="mgtable" style="border-collapse: collapse; "><caption>inner frame of tbody</caption>
<tbody>
 <tr>
  <td style="border:solid 1px red;">a</td>
  <td style="border:solid 1px red;">b</td>
  <td style="border:solid 1px red;">c</td>
 </tr>
 <tr>
  <td style="border:solid 1px red;">d</td>
  <td style="border:solid 1px red;">e</td>
  <td style="border:solid 1px red;">f</td>
 </tr>
 <tr>
  <td style="border:solid 1px red;">g</td>
  <td style="border:solid 1px red;">h</td>
  <td style="border:solid 1px red;">i</td>
 </tr>
</tbody>
</table>

---start mg T4 frame of tbody

|- frame of tbody | b@1green |
| a | b | c |
| d | e | f |
| g | h | i |
|--- footnote1 |

---start html T4
<table class="mgtable" style="border-collapse: collapse; "><caption>frame of tbody</caption>
<tbody style="box-shadow: 0 0 0 1px green;">
 <tr><td>a</td><td>b</td><td>c</td></tr>
 <tr><td>d</td><td>e</td><td>f</td></tr>
 <tr><td>g</td><td>h</td><td>i</td></tr>
</tbody>
<tfoot>
<tr><td colspan="3">footnote1</td></tr>
</tfoot>
</table>

---start mg T5 frame of tfoot

|- frame of footnote | f@1green |
| a | b | c |
| d | e | f |
| g | h | i |
|--- footnote2 |

---start html T5
<table class="mgtable" style="border-collapse: collapse; ">
<caption>
frame of footnote
</caption>
<tbody>
<tr><td>a</td><td>b</td><td>c</td></tr>
<tr><td>d</td><td>e</td><td>f</td></tr>
<tr><td>g</td><td>h</td><td>i</td></tr>
</tbody>
<tfoot style="box-shadow: 0 0 0 1px green;">
<tr><td colspan="3">footnote2</td></tr>
</tfoot>
</table>

---start mg T6 frame of whole table

|- frame of table | t@1green |
| a | b | c |
| d | e | f |
| g | h | i |
|--- footnote3 |

---start html T6
<table class="mgtable" style="border-collapse: collapse; box-shadow: 0 0 0 1px green;">
<caption>
frame of table
</caption>
<tbody>
<tr><td>a</td><td>b</td><td>c</td></tr>
<tr><td>d</td><td>e</td><td>f</td></tr>
<tr><td>g</td><td>h</td><td>i</td></tr>
</tbody>
<tfoot>
<tr><td colspan="3">footnote3</td></tr>
</tfoot>
</table>

---start mg T7 rborder and lborder
|- table with &r and &&&l | border="1" |
|!!&&&l aaaaaaaaa | bbbbbbbbbb | cccccccc |
|&r   d |&&r&&&c&l e | f |
|     g |&r h | i |
| jjjjjjjjjjjjjjjjjjjjjjjjjjjj | kkkkkkkkkkkkkkkkkkkkkkkkkk | lllllllllllllllllllllllllll |

---start html T7
<table class="mgtable" border="1" style="border-collapse: collapse; border: solid 1px;">
<caption> table with &r and &&&l</caption>
<tbody>
<tr><th style="text-align:left;">aaaaaaaaa </th><th style="text-align:center;">bbbbbbbbbb </th><th>cccccccc </th></tr>
<tr style="text-align:right;"><td style="text-align:right;">d </td><td style="text-align:left;">e </td><td>f </td></tr>
<tr><td style="text-align:left;">g </td><td style="text-align:right;">h </td><td>i </td></tr>
<tr><td style="text-align:left;">jjjjjjjjjjjjjjjjjjjjjjjjjjjj </td><td style="text-align:center;">kkkkkkkkkkkkkkkkkkkkkkkkkk </td><td>lllllllllllllllllllllllllll </td></tr>
</tbody>
</table>

---start mg T8 maintext and footnote 1
Table

|- capt.      | border="1"            |
|!        l3 |      e {{^|captE}}    |
|!        l4 |&b    f {{^|captF|+}}  |
|!        l5 |&b    f2{{^|captF2|+}} |
|!        l6 |&b    e2{{^|captE2}}   |
|!        l7 |&b    g {{^|captG|**}} |
|!        l8 |&b    h {{^|captH|d}}  |
|!        l9 |&b    i {{^|captI|**}} |
|--- inner table footnote             |

Main text with footnote{{^|main text footnote}}.
Main text with footnote{{^|main text footnote2|d}}.

---start html T8
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

<hr>
<footer>
<ul style="list-style:none;">
<li><sup>&lowast;1</sup>main text footnote</li>
<li><sup>&dagger;1</sup>main text footnote2</li>
</ul>
</footer>

---start mg T9 maintext and footnote 2
Table

|- capt.      | &c b@2                |
|!        l3 |      e {{^|captE}}    |
|!        l4 |&b    f {{^|captF|+}}  |
|!        l5 |&b    f2{{^|captF2|+}} |
|!        l6 |&b    e2{{^|captE2}}   |
|!        l7 |&b    g {{^|captG|**}} |
|!        l8 |&b    h {{^|captH|d}}  |
|!        l9 |&b    i {{^|captI|**}} |
|--- inner table footnote             |

Main text with footnote{{^|main text footnote}}.
Main text with footnote{{^|main text footnote2|d}}.

|- capt2.     | &c b@2                |
|!        l3 |      e {{^|captE}}    |
|!        l4 |&b    f {{^|captF|+}}  |
|!        l5 |&b    f2{{^|captF2|+}} |
|!        l6 |&b    e2{{^|captE2}}   |
|!        l7 |&b    g {{^|captG|**}} |
|!        l8 |&b    h {{^|captH|d}}  |
|!        l9 |&b    i {{^|captI|**}} |
|--- inner table footnote2            |

Main text with footnote{{^|main text footnote3}}.
Main text with footnote{{^|main text footnote4|d}}.

---start html T9
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
</table>
<p>
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
<sup>&plus;1</sup>captF;&nbsp;
<sup>&plus;2</sup>captF2;&nbsp;
<sup>&lowast;2</sup>captE2;&nbsp;
<sup>&lowast;</sup>captG;&nbsp;
<sup>&dagger;1</sup>captH;&nbsp;
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

---start mg T10a cell width

|$1 a | b |

---start html T10a

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr><td style="width:1px;">a</td><td>b</td></tr>
</tbody>
</table>

---start mg T10b cell height

|$$1 a | b |

---start html T10b

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr style="height:1px;"><td>a</td><td>b</td></tr>
</tbody>
</table>

---start mg T10c cell width/height

|$$1$2 a | b |

---start html T10c

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr style="height:1px;"><td style="width:2px;">a</td><td>b</td></tr>
</tbody>
</table>

---start mg T10c cell width/height 2

|$2$$1 a | b |

---start html T10c

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr style="height:1px;"><td style="width:2px;">a</td><td>b</td></tr>
</tbody>
</table>

---start mg T11 colspan

| a | b | c |
| d |-  | e |

---start html T11

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr><td>a</td><td>b</td><td>c</td></tr>
<tr><td colspan="2">d</td><td>e</td></tr>
</tbody>
</table>

---start mg T12 rowspan

| a | b | c |
|^  | d | e |
| f |^  | g |

---start html T12

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr><td rowspan="2">a</td><td>b</td><td>c</td></tr>
<tr><td rowspan="2">d</td><td>e</td></tr>
<tr><td>f</td><td>g</td></tr>
</tbody>
</table>

---start mg T13a table macro

| a | b |
|<c | d |
|c CCC |

---start html T13a

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr><td>a</td><td>b</td></tr>
<tr><td>CCC</td><td>d</td></tr>
</tbody>
</table>

---start mg T13b table macro 2

| a | b |
|<c | d |
|c  ; c1
|^^ : c1
|^^ : c2

---start html T13b

<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr><td>a</td><td>b</td></tr>
<tr><td>
<dl class="mglist">
<dt>c1</dt><dd>c1</dd>
<dd>c2</dd>
</dl>
</td><td>d</td></tr>
</tbody>
</table>
---end
