#!/usr/bin/env perl

#package Text::Markup::Wini;
use utf8;
use strict;
use warnings;
use Test::More;
use Encode qw/encode decode/;
use lib '.';
use Wini;

our $ENVNAME;
#our %EXT;
our @LANGS;
our $LANG;
our $QUIET;
our %MACROS;
our %VARS;
our %REF;       # dataset for each reference
#our %REFCOUNT;  # reference count
our %REFASSIGN; # reference id definitions
our %TXT;       # messages and forms
our($MI, $MO);  # escape chars to 
our(@INDIR, @INFILE, $OUTFILE);
our($TEMPLATE, $TEMPLATEDIR);

my @indata;

binmode STDIN, ':utf8';
binmode STDERR,':utf8';
binmode STDOUT,':utf8';

my $i=-1;
my $mode = '';
while(<DATA>){
  /^---start mg/   and ($i++, $mode='mg', next);
  /^---start html/ and ($mode='html', next);
  /^---end/ and last;
  $indata[$i]{$mode} .= $_;
}

# do test
for(my $i=0; $i<=$#indata; $i++){
  Text::Markup::Wini::init();
  print STDERR $indata[$i]{mg},"\n";
  my($o, undef) = Text::Markup::Wini::to_html($indata[$i]{mg});
  $o=std($o);

  my $p = $indata[$i]{html};

  # $o must be decoded.
  is $o, std($p);
#  is std(decode('utf-8',$o)), std($p);
}

done_testing;

sub std{
  my($x)=@_;
  $x=~s/[\n\r]//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}/ /g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  $x=~s{(</(?:tr|tbody|table|caption|p|section)>)}{$1\n}g;
  return($x);
}

__DATA__
---start mg
===
lang: 'en'
===

|- Here is a caption | #id1 @2 |
| a | b |

---start html

<table id="id1" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<caption><a href="#id1">Table 1</a> Here is a caption</caption>
<tbody>
<tr><td>a</td><td>b</td></tr>
</tbody>
</table>

---start mg
|- (must be tbl2) | #2 @2 |
| c | d |

---start html

<table id="tbl2" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<caption><a href="#tbl2">Table 2</a>(must be tbl2)</caption>
<tbody>
<tr><td>c</td><td>d</td></tr>
</tbody>
</table>

---start mg

===
lang: 'en'
===

|- | #id1 @2 |
| a | b |

|- (must be tbl2) | #2 @2 |
| c | d |

|- | @2 |
| e | f |

|- (must be tbl3) | #id2 @2 |
| g | h |

|- (must be tbl100) | #100 @2 |
| i | j |

---start html

<table id="id1" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; "><caption><a href="#id1">Table 1</a></caption>
<tbody><tr><td>a</td><td>b</td></tr>
</tbody>
</table>

<table id="tbl2" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; "><caption><a href="#tbl2">Table 2</a>(must be tbl2)</caption>
<tbody><tr><td>c</td><td>d</td></tr>
</tbody>
</table>

<table class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; "><tbody><tr><td>e</td><td>f</td></tr>
</tbody>
</table>

<table id="id2" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; "><caption><a href="#id2">Table 3</a>(must be tbl3)</caption>
<tbody><tr><td>g</td><td>h</td></tr>
</tbody>
</table>

<table id="tbl100" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; "><caption><a href="#tbl100">Table 100</a>(must be tbl100)</caption>
<tbody><tr><td>i</td><td>j</td></tr>
</tbody>
</table>

---start mg

===
lang: 'en'
===

|- | #id1 @2 |
| a | b |

|- (must be tbl2) | #2 @2 |
| c | d |

|- | @2 |
| e | f |

|- (must be tbl3) | #id2 @2 |
| g | h |

|- (must be tbl100) | #100 @2 |
| i | j |

This is main.

{{rr|id1|id2=a|lang=ja}} = id1 ja (must be tbl1) (mainsect: option ja in macro)

{{rr|id1|id2=b|lang=en}} = id1 en (must be tbl1) (mainsect: option en in macro)

? in jp

===
lang: 'ja'
===

This is sub.

|- Here is a caption, which should be in Ja | #id3 @2 |
| a | b |

{{rr|id1|id2=c|lang=ja}} = id1 ja (subsect: option ja in macro)

{{rr|id1|id2=d|lang=en}} = id1 en (subsect: option en in macro)

{{rr|id1|id2=e}} = id1 ja from section val

{{rr|id3|id2=f}} = id3 ja from section val

? in en

===
lang: 'en'
===

{{rr|id2|id2=g}} = id2 en from section val

{{rr|id1|id2=h}} = id1 en from section val

---start html
<table id="id1" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<caption><a href="#id1">Table 1</a></caption>
<tbody>
<tr><td>a </td><td>b </td></tr>
</tbody>
</table>

<table id="tbl2" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<caption>
<a href="#tbl2">Table 2 </a>(must be tbl2)
</caption>
<tbody>
<tr><td>c </td><td>d </td></tr>
</tbody>
</table>

<table class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<tbody>
<tr><td>e</td><td>f</td></tr>
</tbody>
</table>

<table id="id2" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<caption>
<a href="#id2">Table 3 </a>(must be tbl3)
</caption>
<tbody>
<tr><td>g </td><td>h </td></tr>
</tbody>
</table>

<table id="tbl100" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<caption>
<a href="#tbl100">Table 100 </a>(must be tbl100)
</caption>
<tbody>
<tr><td>i </td><td>j </td></tr>
</tbody>
</table>
<p>
This is main.
</p>

<p>
<a href="#id1"> 表1</a>= id1 ja (must be tbl1) (mainsect: option ja in macro)
</p>


<p>
<a href="#id1">Table 1 </a>= id1 en (must be tbl1) (mainsect: option en in macro)
</p>

<section class="mg" id="sect1">
<h1 class="sectiontitle">in jp</h1>

<p>
This is sub.
</p>


<table id="id3" class="mgtable" style="border-collapse: collapse; border-left: solid 2px; border-right: solid 2px; border-bottom: solid 2px; border-top: solid 2px; ">
<caption>
<a href="#id3"> 表4</a>Here is a caption, which should be in Ja
</caption>
<tbody>
<tr><td>a </td><td>b </td></tr>
</tbody>
</table>
<p>
<a href="#id1"> 表1</a>= id1 ja (subsect: option ja in macro)
</p>

<p>
<a href="#id1">Table 1 </a>= id1 en (subsect: option en in macro)
</p>

<p>
<a href="#id1"> 表1</a>= id1 ja from section val
</p>

<p>
<a href="#id3"> 表4</a>= id3 ja from section val
</p>
</section> <!-- end of "sect1" d=ld=1 lastdepth=1 -->

<section class="mg" id="sect2">
<h1 class="sectiontitle">in en</h1>

<p>
<a href="#id2">Table 3 </a>= id2 en from section val
</p>

<p>
<a href="#id1">Table 1 </a>= id1 en from section val
</p>

</section>

---end
