#!/usr/bin/env perl

package Text::Markup::Wini;
use utf8;
use strict;
use warnings;
use Test::More;
use Encode qw/encode decode/;
use lib '.';
use Wini;

binmode STDIN, ':utf8';
binmode STDERR,':utf8';
binmode STDOUT,':utf8';
init();

sub std{
  my($x)=@_;
  $x=~s/[\n\r]+/\n/g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}/ /g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  return($x);
}


{
  my($o, undef) = to_html(<<'EOC');
===
lang: 'en'
===

|- Here is a caption | #id1 @2 |
| a | b |

|- | #2 @2 |
| c | d |

|- | @2 |
| e | f |

|- | #id2 @2 |
| g | h |

|- | #100 @2 |
| i | j |


This is main.

{{rr|id1|id2=a|lang=ja}} = id1 ja (mainsect: option ja in macro)

{{rr|id1|id2=b|lang=en}} = id1 en (mainsect: option en in macro)


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

EOC
  open(my $fho, '>:utf8', 'table_id.html');
  print {$fho} "$o\n"; close $fho;
  $o=std($o);

my $p = <<EOC;

<table id="id1" class="mgtable" style="border-collapse: collapse; ">
<caption>
Table 1: Here is a caption</caption>
<tbody>
<tr><td> a </td><td> b </td></tr>
</tbody>
</table>
<table id="tbl2" class="mgtable" style="border-collapse: collapse; ">
<caption>
Table 2:</caption>
<tbody>
<tr><td> c </td><td> d </td></tr>
</tbody>
</table>
<table class="mgtable" style="border-collapse: collapse; ">
<tbody>
<tr><td> e</td><td> f</td></tr>
</tbody>
</table>
<table id="id2" class="mgtable" style="border-collapse: collapse; ">
<caption>
Table 3:</caption>
<tbody>
<tr><td> g </td><td> h </td></tr>
</tbody>
</table>
<table id="tbl100" class="mgtable" style="border-collapse: collapse; ">
<caption>
Table 100:</caption>
<tbody>
<tr><td> i </td><td> j </td></tr>
</tbody>
</table>
<p>
This is main.</p>


<p>
表1 = id1 ja (mainsect: option ja in macro)</p>


<p>
Table 1 = id1 en (mainsect: option en in macro)
</p>

<section class="mg" id="sect1">
<h1 class="sectiontitle">in jp</h1>



<p>
This is sub.</p>


<table id="id3" class="mgtable" style="border-collapse: collapse; ">
<caption>
Table 6: Here is a caption, which shold be in Ja</caption>
<tbody>
<tr><td> a </td><td> b </td></tr>
</tbody>
</table>
<p>
表1： = id1 ja (subsect: option ja in macro)</p>


<p>
Table 1: = id1 en (subsect: option en in macro)</p>


<p>
Table 1: = id1 ja from section val</p>


<p>
Table 6 = id3 ja from section val
</p>
</section> <!-- end of "sect1" d=ld=1 lastdepth=1 -->

<section class="mg" id="sect2">
<h1 class="sectiontitle">in en</h1>



<p>
Table 3 = id2 en from section val</p>


<p>
Table 1 = id1 en from section val
</p>

</section>

EOC

  # $o must be decoded.
  is std($o), std($p);
#  is std(decode('utf-8',$o)), std($p);
}


done_testing;
