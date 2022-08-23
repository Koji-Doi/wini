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

for(my $i=1; $i<=$#indata; $i++){
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

---start mg 1

{{ev|"Aa, Bb"|&ini_f}}

---start html 1

<p>
Aa, B.
</p>

---start mg 2

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,;}}

---start html 2

<p>
Aa, B., Cc, D.; Ee, F.
</p>

---start mg 3

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,&}}

---start html 3

<p>
Aa, B., Cc, D. &amp; Ee, F.
</p>

---start mg 4

{{ev|"Aa, Bb"|"Cc, Dd"|"Ee, Ff"|&ini_f|&join,a}}

---start html 4

<p>
Aa, B., Cc, D. and Ee, F.
</p>

---end
