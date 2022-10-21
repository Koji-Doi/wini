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
$ENV{LANG}='C';
Text::Markup::Wini::init();

our %REF;
my @indata;
my $i=0;
my $mode="";
my @reflist;
$_=<DATA>;
while(<DATA>){
  if(/^---start reflist/ .. /---end reflist/){
    /^---/ or push(@reflist, $_);
  }else{
    /^---start mg(?:\s*(.*))?$/ and ($i++, $mode='mg', $indata[$i]{tag}=$1, next);
    /^---start html/ and ($mode='html', next);
    /^---end/ and last;
    $indata[$i]{$mode} .= $_;
  }
}

for(my $i=1; $i<=$#indata; $i++){
  Text::Markup::Wini::init();
  if((scalar @reflist)>0){
    my $tmpreffile = "tempref.$$.enw";
    open(my $fho, '>:utf8', $tmpreffile) or die "Cannot create tempfile: $tmpreffile";
    print {$fho} join('', @reflist);
    close $fho;
    Text::Markup::Wini::read_bib($tmpreffile);
    unlink $tmpreffile;
  }

  my($o1) = Text::Markup::Wini::to_html($indata[$i]{mg});
  my($mgfile, $htmlfile) =("bib_t$i.wini", "bib_t$i.html");
  open(my $fho_w, '>:utf8', $mgfile);
  print {$fho_w} $indata[$i]{mg};
  close $fho_w;
  open(my $fho_h, '>:utf8', $htmlfile);
  print {$fho_h} $o1;
  close $fho_h;

  is1( std($o1), std($indata[$i]{html}), $indata[$i]{tag});
  unlink $mgfile, $htmlfile;
}
1;
done_testing;

__DATA__
"

---start mg 1-1 &ini_f

{{ev|"Aa, Bb"|&ini_f}}

---start html 1-1

<p>
Aa, B.
</p>

---start mg 1-2 &ini_f|&join,;

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,;}}

---start html 1-2

<p>
Aa, B., Cc, D.; Ee, F.
</p>

---start mg 1-3 &ini_f|&join,&

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,&}}

---start html 1-3

<p>
Aa, B., Cc, D. &amp; Ee, F.
</p>

---start mg 1-4 &ini_f|&join,a

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,a}}

---start html 1-4

<p>
Aa, B., Cc, D. and Ee, F.
</p>

---start mg 2-1 &lastname|&join,a

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&lastname|&join,a}}

---start html 2-1

<p>
Aa, Cc and Ee
</p>

---start mg 2-2 &lastname|&join,&

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&lastname|&join,&}}

---start html 2-2

<p>
Aa, Cc &amp; Ee
</p>

---start mg 3 &uc_all

  {{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|"gg"|"HH"|"iI"|&uc_all|&join;;}}

---start html 3

<p>
AA, BB; CC, DD; EE, FF; GG; HH; II
</p>

---start mg 4 &last_first

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|"Gg, H Ii"|&last_first|&join;;}}

---start html 4

<p>
Aa Bb; Cc Dd; Ee Ff; Gg H Ii
</p>

---start mg 5 &first_last

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|"Gg, H Ii"|&first_last|&join;;}}

---start html 5

<p>
Bb Aa; Dd Cc; Ff Ee; H Ii Gg
</p>

---start mg 6-1 split

{{ev|"a b c"|"d e f"|&split|&sortr|&join,,}}

---start html 6-1
<p>
f, e, d, c, b, a
</p>

---start mg 6-2 join

{{ev|"A"|"B"|"C"|"D"|"E"|&join}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join,}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join;}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join,a}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join,&}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join2e}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join3e}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join;;2e}}

{{ev|"A"|"B"|"C"|"D"|"E"|&join;;3e}}

---start html 6-2
<p>A, B, C, D E</p>
<p>A, B, C, D E</p>
<p>A; B; C; D E</p>
<p>A, B, C, D and E</p>
<p>A, B, C, D &amp; E</p>
<p>A B et al.</p>
<p>A, B C et al.</p>
<p>A; B et al.</p>
<p>A; B; C et al.</p>

---start mg 7 sort

{{ev|1|3|2|&sort|&join,&}}
{{ev|10|3|2|&sort|&join,&}}
{{ev|1|3|20|4|&sort|&join,&}}
{{ev|1|3|20|4|&sortn|&join,&}}

{{ev|1|3|2|&sortr|&join,&}}
{{ev|10|3|2|&sortr|&join,&}}
{{ev|1|3|20|4|&sortr|&join,&}}
{{ev|1|3|20|4|&sortnr|&join,&}}

---start html 7 sort

<p>
1, 2 &amp; 3
10, 2 &amp; 3
1, 20, 3 &amp; 4
1, 3, 4 &amp; 20
</p>

<p>
3, 2 &amp; 1
3, 2 &amp; 10
4, 3, 20 &amp; 1
20, 4, 3 &amp; 1
</p>

---start mg 8 quote

{{ev|"abc"|&q_}}

---start html 8 quote

<p>
'abc'
</p>

---start mg 9 numeric calc

{{ev|2022|1965|-}}
{{ev|1|1|+}}
{{ev|1|1|+|4|-}}

---start html 9 numeric calc

<p>
57
2
-2
</p>

---start mg 10 &morethan

{{ev|1|2|3|4|5|&morethan 4}},
{{ev|1|2|3|4|5|&morethan 5}},
{{ev|1|2|3|4|5|&morethan 6}}

---start html 10

<p>5, ,</p>

---start mg 11 &cut

{{ev|1|2|3|4|5|&cut_lt 4|&join,,}}

{{ev|1|2|3|4|5|&cut_le 4|&join,,}}

{{ev|1|2|3|4|5|&cut_gt 4|&join,,}}

{{ev|1|2|3|4|5|&cut_ge 4|&join,,}}

---start html 11

<p>1, 2, 3</p>
<p>1, 2, 3, 4</p>
<p>5</p>
<p>4, 5</p>

---start mg 12 &l_, &r_

{{ev|"a"|"b"|"c"|&l_&amp;|&join,,}}

{{ev|"a"|"b"|"c"|&r_&amp;|&join,,}}

---start html 12

<p>
&amp;a, &amp;b, &amp;c
</p>
<p>
a&amp;, b&amp;, c&amp;
</p>

---start mg 13 &bold, &ita

{{ev|"a"|&bold}}

{{ev|"a"|&ita}}

{{ev|"a"|&italic}}


---start html 13

<p>
&nbsp;<span style="font-weight:bold">a</span>
</p>
<p>
&nbsp;<span style="font-style:italic">a</span>
</p>
<p>
&nbsp;<span style="font-style:italic">a</span>
</p>

---start mg 14 &if_empty

===
xxx: 'abc'
===

{{ev|xxx}}

---start html 14

<p>abc</p>

---start mg 15 section variables
===
cmd: --title test
a:1
b:2
 c:3
===

Value of variable 'a' should be 1, is {{va|a}}.
Value of variable 'b' should be 2, is {{va|b}}.
Env name is {{envname}}.

? xxx

===
b:333
===

xxxx

Value of variable 'a' should be 1, is {{va|a}}.
Value of variable 'b' should be 333, is {{va|b}}.
Env name is {{envname}}.

?? yyy

===
c:444
===

Value of variable 'a' should be 1, is {{va|a}}.
Value of variable 'b' should be 333, is {{va|b}}.
Value of variable 'c' should be 444, is {{va|c}}.

---start html 15

<p>
Value of variable 'a' should be 1, is 1.
Value of variable 'b' should be 2, is 2.
Env name is _.
</p>

<section class="mg" id="sect1">
<h1 class="sectiontitle">xxx</h1>

<p>
xxxx
</p>

<p>
Value of variable 'a' should be 1, is 1.
Value of variable 'b' should be 333, is 333.
Env name is _.
</p>

<section class="mg" id="sect2">
<h1 class="sectiontitle">yyy</h1>

<p>
Value of variable 'a' should be 1, is 1.
Value of variable 'b' should be 333, is 333.
Value of variable 'c' should be 444, is 444.
</p>

</section></section>

---end
