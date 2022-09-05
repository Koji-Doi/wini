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
