#!/usr/bin/env perl

package Text::Markup::Wini;
use utf8;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;

binmode STDIN, ':utf8';
binmode STDERR,':utf8';
binmode STDOUT,':utf8';
init();

sub std{
  my($x)=@_;
  $x=~s/[\n\r]*//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}//g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  return($x);
}


{
  my($o, undef) = to_html(<<'EOC');
===
lang: 'en'
===

|- Here is a caption | #id1 |
| a | b |

|- | #2 |
| c | d |

|- | |
| e | f |

|- | #id2 |
| g | h |

|- | #100 |
| i | j |


Thi is main.

{{rr|id1|lang=ja}} = id1 ja (mainsect: option ja in macro)

{{rr|id1|lang=en}} = id1 en (mainsect: option en in macro)


? in jp

===
lang: 'ja'
===

This is sub.

|- Here is a caption, which shold be in Ja | #id3 |
| a | b |

{{rr|id1|lang=ja}} = id1 ja (subsect: option ja in macro)

{{rr|id1|lang=en}} = id1 en (subsect: option en in macro)

{{rr|id1}} = id1 ja from section val

{{rr|id3}} = id3 ja from section val

? in en

===
lang: 'en'
===

{{rr|id2}} = id2 en from section val

{{rr|id1}} = id1 en from section val




EOC
  $o=std($o);

my $p = <<EOC;




<table id="id1" class="winitable" style="border-collapse: collapse; ">
<caption>
Table 1  Here is a caption</caption>
<tbody>
<tr><td> a </td><td> b </td></tr>
</tbody>
</table>
<table id="tbl2" class="winitable" style="border-collapse: collapse; ">
<caption>
Table 2</caption>
<tbody>
<tr><td> c </td><td> d </td></tr>
</tbody>
</table>
<table class="winitable" style="border-collapse: collapse; ">
<caption></caption>
<tbody>
<tr><td> e</td><td> f</td></tr>
</tbody>
</table>
<table id="id2" class="winitable" style="border-collapse: collapse; ">
<caption>
Table 3</caption>
<tbody>
<tr><td> g </td><td> h </td></tr>
</tbody>
</table>
<table id="tbl100" class="winitable" style="border-collapse: collapse; ">
<caption>
Table 100</caption>
<tbody>
<tr><td> i </td><td> j </td></tr>
</tbody>
</table>
<p>
Thi is main.</p>


<p>
表1 = id1 ja (mainsect: option ja in macro)</p>


<p>
Table 1 = id1 en (mainsect: option en in macro)
</p>

<section class="wini" id="sect1">
<h1 class="sectiontitle">in jp</h1>



<p>
This is sub.</p>


<table id="id3" class="winitable" style="border-collapse: collapse; ">
<caption>
Table 6  Here is a caption, which shold be in Ja</caption>
<tbody>
<tr><td> a </td><td> b </td></tr>
</tbody>
</table>
<p>
表1 = id1 ja (subsect: option ja in macro)</p>


<p>
Table 1 = id1 en (subsect: option en in macro)</p>


<p>
Table 1 = id1 ja from section val</p>


<p>
Table 6 = id3 ja from section val
</p>
</section> <!-- end of "sect1" d=ld=1 lastdepth=1 -->

<section class="wini" id="sect2">
<h1 class="sectiontitle">in en</h1>



<p>
Table 3 = id2 en from section val</p>


<p>
Table 1 = id1 en from section val
</p>

</section>

EOC
  $p=std($p);

  is $o, $p;
}


done_testing;
