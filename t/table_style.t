#!/usr/bin/perl

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
Text::Markup::Wini::init();

our %REF;
my @indata;
my $i=0;
my $mode="";
$_=<DATA>;
while(<DATA>){
    /^---start mg/   and ($i++, $mode='mg', next);
    /^---start html/ and ($mode='html', next);
    /^---end/ and last;
    $indata[$i]{$mode} .= $_;
}

for(my $i=1; $i<=$#indata; $i++){
  Text::Markup::Wini::init();
  my($o1) = Text::Markup::Wini::to_html($indata[$i]{mg});
  is std($o1), std($indata[$i]{html});
}
1;
done_testing;

__DATA__
"

---start mg 1

|- no border line | |
| a | b | c |
| d | e | f |
| g | h | i |

---start html 1
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

---start mg 2

|- outer frame | @1 |
| a | b | c |
| d | e | f |
| g | h | i |

---start html 2
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

---start mg 3

|- inner frame of tbody | @@1 |
| a | b | c |
| d | e | f |
| g | h | i |

---start html 3

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

---end
