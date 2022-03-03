#!/usr/bin/perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;
init();

my @indata;
my $i=0;
while(<DATA>){
  /^---start mg/   and ($i++, $mode='mg');
  /^---start html/ and ($mode='html');
  push(@{$data[$i]{$mode}}, $_);
  /^---end/ and last;
}

for(my $i=0; $i<=$#data; $i++){
  my $o0 = join('', @{$data[$i]{mg}});
  my $o1 = markgaab($x);
  is $o1, $o0;
}

done_testing;

__DATA__
---start mg
Reference 1: {{bib|kirk2022|au='James, T. Kirk'|ye=2022|ti='XXX'}}

Referene 2: {{bib|gal2021|au='Kadotani, Anzu'|au='Koyama, Yuzuko'|au='Kawashima, Momo'|yr=2021|ti='Practice of Senshado in High School Club Activities'}}

aaa {{ref|kirk2022}}, {{ref|gal2021}}.

{{biblist}}

---start html

---end
