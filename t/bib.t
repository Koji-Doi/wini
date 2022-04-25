#!/usr/bin/perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;
Text::Markup::Wini::init();

sub std{
  my($x)=@_;
  $x=~s/[\n\r]//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}/ /g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  $x=~s{(</\w+>)}{$1\n}g;
  return($x);
}

my @indata;
my $i=0;
my $mode="";
while(<DATA>){
  /^---start mg/   and ($i++, $mode='mg', next);
  /^---start html/ and ($mode='html', next);
  /^---end/ and last;
  $indata[$i]{$mode} .= $_;
}

for(my $i=1; $i<=$#indata; $i++){
  my($o1) = Text::Markup::Wini::to_html($indata[$i]{mg});
#  $o1              =~s/[\s\n]//g;
#  $indata[$i]{html}=~s/[\s\n]//g;
  is std($o1), std($indata[$i]{html});
}
1;
done_testing;

__DATA__
---start mg

Reference 1: {{cit|kirk2022|au='James, T. Kirk'|ye=2022|ti='XXX'}}

Reference 2: {{cit|gal2021|au='Kadotani, Anzu'|au='Koyama, Yuzuko'|au='Kawashima, Momo'|ye=2021|ti='Practice of Senshado in High School Club Activities'|jo='Research by Highschool Students'}}

aaa {{ref|kirk2022}}, {{ref|gal2021}}.

{{citlist}}

---start html
<p>
Reference 1:  [1] </p>


<p>
Referene 2:  [2] </p>


<p>
aaa  [1] ,  [2] .</p>



<ul class="mglist reflist">
<li>
 kirk2022
</li>
<li>
 gal2021
</li>
</ul>

---end
