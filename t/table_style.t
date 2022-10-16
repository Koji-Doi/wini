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
our $DEBUG=0;
if(defined $ARGV[0] and $ARGV[0] eq '-d'){
  $DEBUG=1;
}

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
  #Text::Markup::Wini::init();
  #my($o1) = Text::Markup::Wini::to_html($indata[$i]{mg});
  #is std($o1), std($indata[$i]{html});
  test1($indata{tag}[$i], $indata{mg}[$i], $indata{html}[$i]);
}
1;
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

<table class="mgtable" style="border-collapse: collapse; "><caption>frame of tbody</caption>
<tbody style="box-shadow: 0 0 0 1px green;">
 <tr><td>a</td><td>b</td><td>c</td></tr>
 <tr><td>d</td><td>e</td><td>f</td></tr>
 <tr><td>g</td><td>h</td><td>i</td></tr>
</tbody>
<tfoot>
<tr><td colspan="3">footnote3</td></tr>
</tfoot>
</table>
---end
