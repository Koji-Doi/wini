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
  if(/^=$/){next}
  if(/^---start reflist/ .. /---end reflist/){
    /^---/ or push(@reflist, $_);
  }else{
    /^---start mg(?:\s*(.*))?$/ and ($i++, $mode='mg', $indata[$i]{tag}=$1, next);
    /^---start html/ and ($mode='html', next);
    /^---end/ and last;
    $indata[$i]{$mode} .= $_;
    $indata[$i]{$mode} =~ s/^\s*$//s;
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
---start mg 1 min,max

{{ev|1|3|2|44|5|&nmin}}
{{ev|1|3|2|44|5|&nmini}}

{{ev|1|3|2|44|5|&nmax}}
{{ev|1|3|2|44|5|&nmaxi}}

{{ev|"1"|"3"|"2"|"44"|"5"|&tmin}}
{{ev|"1"|"3"|"2"|"44"|"5"|&tmini}}

{{ev|"1"|"3"|"2"|"44"|"5"|&tmax}}
{{ev|"1"|"3"|"2"|"44"|"5"|&tmaxi}}

---start html 1

<p>
1 0
</p>
<p>
44 3
</p>
<p>
1 0
</p>
<p>
5 4
</p>

---start mg 2-1 &ini_f

{{ev|"Aa, Bb"|&ini_f}}

---start html 2-1

<p>
Aa, B.
</p>

---start mg 2-2 &ini_f|&join,;

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,;}}

---start html 2-2

<p>
Aa, B., Cc, D.; Ee, F.
</p>

---start mg 2-3 &ini_f|&join,&

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,&}}

---start html 2-3

<p>
Aa, B., Cc, D. &amp; Ee, F.
</p>

---start mg 2-4 &ini_f|&join,a

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,a}}

---start html 2-4

<p>
Aa, B., Cc, D. and Ee, F.
</p>

---start mg 3-1 &lastname|&join,a

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&lastname|&join,a}}

---start html 3-1

<p>
Aa, Cc and Ee
</p>

---start mg 3-2 &lastname|&join,&

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&lastname|&join,&}}

---start html 3-2

<p>
Aa, Cc &amp; Ee
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
<p>A, B, C, D, E</p>
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
{{ev|"abc"|&q_()}}

---start html 8 quote

<p>
'abc'
(abc)
</p>

---start mg 9-1 calc (num)
{{ev|2022|1965|-}}
{{ev|1|1|+}}
{{ev|1|1|+|4|-}}
{{ev|1.1|2.2|+}}
  
---start html 9-1 calc (num)

<p>
57
2
-2
3.3
</p>

---start mg 9-2 calc (num cmp)
{{ev|1|1|==}}
{{ev|1.1|1.10|==}}
{{ev|33|4|>}}
{{ev|-1|-2|>}}

---start html 9-2

<p>
1
1
1
1
</p>

---start mg 9-3 calc (num cmp2)
{{ev|1.0|1|!=}}
{{ev|33|4|<}}
{{ev|-1|1|>}}

---start html 9-3 calc (num cmp2)

---start mg 9-4 calc (char cmp)
{{ev|"1"|"1"|&eq}}
{{ev|"1.1"|"1.10"|&ne}}

---start html 9-4
<p>
1
1
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
{{ev|"a"|"b"|"c"|&l_&ast;|&join,,}}
{{ev|"a"|"b"|"c"|&l_|&join,,}}

{{ev|"a"|"b"|"c"|&r_&amp;|&join,,}}
{{ev|"a"|"b"|"c"|&r_&ast;|&join,,}}
{{ev|"a"|"b"|"c"|&r_|&join,,}}

---start html 12

<p>
&amp;a, &amp;b, &amp;c
&ast;a, &ast;b, &ast;c &ast;a, &ast;b, &ast;c
</p>
<p>
a&amp;, b&amp;, c&amp;
a&ast;, b&ast;, c&ast;
a., b., c.
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

---start mg 14 &ucase, &ucase1, &lcase, &lcase1

{{ev|"abc"|"xyz"|&ucase|&join}}

{{ev|"abc"|"xyz"|&ucase1|&join}}

{{ev|"ABC"|"XYZ"|&lcase|&join}}

{{ev|"ABC"|"XYZ"|&lcase1|&join}}

---start html 14

<p>
ABC, XYZ
</p>
<p>
Abc, Xyz
</p>
<p>
abc, xyz
</p>
<p>
aBC, xYZ
</p>

---start mg 15 &if_empty

===
xxx: 'abc'
===

{{ev|xxx}}

---start html 15

<p>abc</p>

---start mg 16 move etc.

join: {{ev|11|1|2|3|1|&uniq|&join}}

union: {{ev|11|1|2|3|1|&move>x|2|3|4|&union _ x|&join}}

isec: {{ev|11|1|2|3|1|&move>x|2|3|4|&isec _ x|&join}}

sdiff1: {{ev|11|1|2|3|&move>x|2|3|4|&sdiff _ x|&join}}

sdiff2: {{ev|11|1|2|3|1|&move>x|2|3|4|&sdiff x _|&join}}

sdiff3: {{ev|11|1|2|3|1|&move>x|2|3|4|1|1|2|&sdiff x _|&join}}

sdiff4: {{ev|11|1|2|3|1|&move>x|2|4|1|2|&sdiff x _|&join}}

sdiff5: {{ev|11|1|2|3|1|&move>x|2|4|1|2|&move>y|&sdiff y x|&join}}

sdiff6: {{ev|11|1|2|3|1|&move>x|2|4|1|2|&move>y|&sdiff x y|&join}}

---start html 16
<p>join: 1, 11, 2, 3</p>
<p>union: 1, 11, 2, 3, 4</p>
<p>isec: 2, 3</p>
<p>sdiff1: 4</p>
<p>sdiff2: 1, 11</p>
<p>sdiff3: 11</p>
<p>sdiff4: 11, 3</p>
<p>sdiff5: 4</p>
<p>sdiff6: 11, 3</p>

---start mg 17 front matter
===
a: 123
===

a={{ev|a}} (123)

---start html 17
<p> a=123 (123)</p>

---start mg 18 front matter with subsection
===
a: 123
===

?#sub1 subsection 1

a={{ev|a}} (123)

---start html 18
<section class="mg" id="sub1">
<h1 class="sectiontitle">
subsection 1
</h1>
<p>a=123 (123)</p>
</section>

---start mg 19 front matter with subsection front matter
===
a: 123
===

? subsection 1

===
b: 456
===

a={{ev|a}} (123)
b={{ev|b}} (456)

---start html 19
<section class="mg" id="sect1">
<h1 class="sectiontitle">
subsection 1
</h1>
<p>a=123 (123) b=456 (456)</p>
</section>

---start mg 20 front matter with subsubsection front matter
===
a: 123
===

sectid={{sectid}}

? subsection 1

===
b: 456
===

a={{ev|a}} (123)
b={{ev|b}} (456)
c={{ev|c}}
sectid={{sectid}}

?? subsubsection 1

===
c: 789
===

a={{ev|a}} (123)
b={{ev|b}} (456)
c={{ev|c}}
sectid={{sectid}}

---start html 20
<p>sectid=</p>
<section class="mg" id="sect1">
<h1 class="sectiontitle">subsection 1</h1>
<p>a=123 (123) b=456 (456) c= sectid=sect1</p>
<section class="mg" id="sect2">
<h1 class="sectiontitle">subsubsection 1</h1>
<p>a=123 (123) b=456 (456) c=789 sectid=sect2</p>
</section>
</section>

---end
