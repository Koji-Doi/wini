#!/usr/bin/perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;

use lib '.';
use Wini;
use is;
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
    /^---start mg/   and ($i++, $mode='mg', next);
    /^---start html/ and ($mode='html', next);
    /^---end/ and last;
    $indata[$i]{$mode} .= $_;
  }
}

SKIP: for(my $i=1; $i<=$#indata; $i++){
#for (my $i=3; $i==3; $i++){
#  undef %Text::Markup::Wini::REF;
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
open(my $fho_w, '>:utf8', "bib_t$i.wini");
print {$fho_w} $indata[$i]{mg};
close $fho_w;
open(my $fho_h, '>:utf8', "bib_t$i.html");
print {$fho_h} $o1;
close $fho_h;

#  $o1              =~s/[\s\n]//g;
#  $indata[$i]{html}=~s/[\s\n]//g;
  is1 std($o1), std($indata[$i]{html});
}
1;
done_testing;

__DATA__
"
---start reflist
%0 Journal Article
%T sample 1 title
%A Kadotani, A
%J sample 1 journal
%D 2022

%0 Journal Article
%T sample 2 title
%A Kadotani, A
%J sample 2 journal
%D 2022

%0 Journal Article
%T sample 3 title
%A Kadotani, A
%A Koyama, Y
%J sample 3 journal
%D 2022

%0 Journal Article
%T Enrichr: interactive and collaborative HTML5 gene list enrichment analysis tool
%A Chen, Edward Y
%A Tan, Christopher M
%A Kou, Yan
%A Duan, Qiaonan
%A Wang, Zichen
%A Meirelles, Gabriela Vaz
%A Clark, Neil R
%A Ma’ayan, Avi
%J BMC bioinformatics
%V 14
%N 1
%P 1-14
%@ 1471-2105
%D 2013
%I BioMed Central

%0 Generic
%T Mojolicious. Real-time web framework
%A Riedel, Sebastian
%D 2008

%0 Conference Proceedings
%T P2P media streaming with HTML5 and WebRTC
%A Nurminen, Jukka K
%A Meyn, Antony JR
%A Jalonen, Eetu
%A Raivio, Yrjo
%A Marrero, Raul Garc?a
%B 2013 IEEE Conference on Computer Communications Workshops (INFOCOM WKSHPS)
%P 63-64
%@ 1479900567
%D 2013
%I IEEE
---end reflist

---start mg 1

Reference 1: {{cit|kirk2282|au='James, T. Kirk'|ye=2282|ti='Federation Starfleet{{'}}s New Operation Concept.'|jo='Federation Military Review' |vo='100' |pp='201-202' }}

---start html 1

<p>
Reference 1:<a href="#reflist_kirk2282"><span id="kirk2282_1" title="title">(1)</span></a>
</p>

---start mg 2

Reference 1: {{cit|kirk2282|au='James, T. Kirk'|ye=2282|ti='Federation Starfleet{{'}}s New Operation Concept.'|jo='Federation Military Review' |vo='100' |pp='201-202' }}

Reference 2: {{cit|gal2021|au='Kadotani, Anzu'|au='Koyama, Yuzuko'|au='Kawashima, Momo' | ye=2021 | ti='Practice of Senshado in High School Club Activities' | jo='Research by Highschool Students' | vo=20 | pp='101-111' }}

Citing ref 1 as {{ref|kirk2282}}.

Citing ref 2 as {{ref|gal2021}}.

---start html 2

<p>
Reference 1:<a href="#reflist_kirk2282"><span id="kirk2282_1" title="title">(1)</span></a>
</p>

<p>
Reference 2:<a href="#reflist_gal2021"><span id="gal2021_1" title="title">(2)</span></a>
</p>

<p>Citing ref 1 as<a href="#reflist_kirk2282"><span id="kirk2282_2" title="title">(1)</span></a>.</p>
<p>Citing ref 2 as<a href="#reflist_gal2021"><span id="gal2021_2" title="title">(2)</span></a>.</p>

---start mg 3

Reference 1: {{cit|kirk2282|au='James, T. Kirk'|ye=2282|ti='Federation Starfleet{{'}}s New Operation Concept.'|jo='Federation Military Review' |vo='100' |pp='201-202' }}

Reference 2: {{cit|gal2021|au='Kadotani, Anzu'|au='Koyama, Yuzuko'|au='Kawashima, Momo' | ye=2021 | ti='Practice of Senshado in High School Club Activities' | jo='Research by Highschool Students' | vo=20 | pp='101-111' }}

Citing ref 1 as {{ref|kirk2282}}.

Citing ref 2 as {{ref|gal2021}}.

Citing ref 1 again as {{ref|kirk2282}}.

---start html 3

<p>
Reference 1:<a href="#reflist_kirk2282"><span id="kirk2282_1" title="title">(1)</span></a>
</p>

<p>
Reference 2:<a href="#reflist_gal2021"><span id="gal2021_1" title="title">(2)</span></a>
</p>

<p>
Citing ref 1 as<a href="#reflist_kirk2282"><span id="kirk2282_2" title="title">(1)</span></a>
.</p>
<p>
Citing ref 2 as<a href="#reflist_gal2021"><span id="gal2021_2" title="title">(2)</span></a>
.</p>
<p>Citing ref 1 again as<a href="#reflist_kirk2282"><span id="kirk2282_3" title="title">(1)</span></a>
.</p>

---start mg 4

{{cit|gal2021|au='Kadotani, Anzu'|au='Koyama, Yuzuko'|au='Kawashima, Momo'|ye=2021|ti='Practice of Senshado in High School Club Activities'|jo='Research by Highschool Students'}}

{{citlist}}

---start html 4

<p><a href="#reflist_gal2021"><span id="gal2021_1" title="title">(1)</span></a></p>
<ul class="citlist"><li id="gal2021">[1]<a href="#gal2021_1">^1&nbsp;</a>
Kadotani, A. and Koyama, Y. et al. (2021) Practice of Senshado in High School Club Activities. Research by Highschool Students</li>
</ul>

---end
