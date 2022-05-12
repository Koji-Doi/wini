#!/usr/bin/perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;

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

for(my $i=1; $i<=$#indata; $i++){
  undef %Text::Markup::Wini::REF;
  if((scalar @reflist)>0){
    my $tmpreffile = "tempref.$$.enw";
    open(my $fho, '>:utf8', $tmpreffile) or die "Cannot create tempfile: $tmpreffile";
    print {$fho} join('', @reflist);
    close $fho;
    Text::Markup::Wini::read_bib($tmpreffile);
    unlink $tmpreffile;
    #print STDERR Dumper %Text::Markup::Wini::REF;
    $DB::single=$DB::single=1;
1;
  }

  my($o1) = Text::Markup::Wini::to_html($indata[$i]{mg});
#  $o1              =~s/[\s\n]//g;
#  $indata[$i]{html}=~s/[\s\n]//g;
  is std($o1), std($indata[$i]{html});
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

---start mg

Reference 1: {{cit|kirk2022|au='James, T. Kirk'|ye=2022|ti='XXX'}}

Reference 2: {{cit|gal2021|au='Kadotani, Anzu'|au='Koyama, Yuzuko'|au='Kawashima, Momo'|ye=2021|ti='Practice of Senshado in High School Club Activities'|jo='Research by Highschool Students'}}

aaa {{ref|kirk2022}}, {{ref|gal2021}}.

{{citlist}}

---start html
<p>
Reference 1:  [1] </p>


<p>
Reference 2:  [2] </p>


<p>
aaa  [1],  [2].</p>



<ul class="mglist reflist">
<li>
 kirk2022
</li>
<li>
 gal2021
</li>
</ul>

---start mg

{{rr|chen2013}}.

{{citlist}}

---start html

---end
