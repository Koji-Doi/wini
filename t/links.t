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
our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;
Text::Markup::Wini::init();
$ENV{LANG}='C';

sub std1{
  my($x)=@_;
  $x = std($x);
  $x=~s{(</\w+>)}{$1\n}g;
  return($x);
}

our %REF;
my @indata;
my $i=0;
my $mode="";
my @reflist;
while(<DATA>){
  /^"$/ and next;
  /^---start mg(?:\s*(.*))?$/ and ($i++, $mode='mg', $indata[$i]{tag}=$1, next);
  /^---start html/ and ($mode='html', next);
  /^---start log/  and ($mode='log', next);
  /^---end/ and last;
  $indata[$i]{$mode} .= $_;
}

my @files;
SKIP: for(my $i=1; $i<=$#indata; $i++){
  Text::Markup::Wini::init();

  my $infile   = "links_t$i.wini";
  my $lang     = ($indata[$i]{tag}=~/\[(\w+)\]/) ? $1 : '';
  my $htmlfile = "links_t_${i}_${lang}.html";
  my $errfile  = "links_t_${i}_${lang}.err.txt";
  push(@files, $infile, $htmlfile, $errfile);
  save_obj_to_file($indata[$i]{mg}, $infile);

  my $lang1 = ($lang) ? "--lang $lang" : '';
  my $cmd = "perl Wini.pm --quiet $lang1 < $infile > $htmlfile 2>$errfile";
  ($DEBUG) and print STDERR "$cmd\n";
  system($cmd);
  open(my $fh_h, '<:utf8', $htmlfile);
  my $got = join("\n", <$fh_h>);
  is1(std1($got), std1($indata[$i]{html}), $indata[$i]{tag});

  if($indata[$i]{tag}=~/ e /){
    open(my $fh_log, '<:utf8', $errfile);
    my $got_e = join('', <$fh_log>);
    is1($got_e, $indata[$i]{log}, "$indata[$i]{tag} error log");
  }
}

unless($DEBUG){
  foreach my $f (@files){
    unlink $f;
  }
}

1;
done_testing;

__DATA__
"
---start mg A: links without link text

links without link text.  [http://example.com]

---start html A

<p>
links without link text.  <a href="http://example.com" target="_self">http://example.com</a>
</p>

---start mg B: Links with [http://example.com link text]

Links with [http://example.com link text].

---start html B

<p>
Links with <a href="http://example.com" target="_self">link text</a>.
</p>

---start mg C: links with [link text in markdown-compartible format](http://example.com)

links with [link text in markdown-compartible format](http://example.com)

---start html 3

<p>
links with <a href="http://example.com">link text in markdown-compartible format</a>
</p>

---start mg D: [#hoge inner link]

[#hoge inner link]

---start html 4

<p>
<a href="#hoge" target="_self">inner link</a>
</p>

---start mg E: ext ref

{{.hoge|Paragraph with ID}}

---start html E

<p>
<span class="hoge">Paragraph with ID</span>
</p>

---start mg E2:ext ref

{{#hoge|Paragraph with ID}}

---start html E2

<p>
<span id="hoge">Paragraph with ID</span>
</p>

---start mg img1 simple
[!test.png]

---start html img1
<p>
<img src="test.png" alt="test.png">
</p>

---start mg img2 with fig ID.
[!test.png|#fig1]

---start html img2
<p>
<img src="test.png" alt="test.png" id="fig1">
</p>

---start mg img2 with fig ID.
[!test.png|#fig1]

---start html img2
<p>
<img src="test.png" alt="test.png" id="fig1">
</p>

---start mg img3 with figure tag

[!!test.png]

---start html img3
<figure><img src="test.png" alt="test.png"><figcaption>test.png</figcaption></figure>

---start mg img4 with anchor
[?test.png]

---start html img4
<p>
<a href="test.png" target="_self"><img src="test.png" alt="test.png"></a>
</p>

---start mg img4 with ID and caption
[!!test.png|#fig1]

---start html img4
<figure><img src="test.png" alt="test.png" id="fig1"><figcaption><a href="#fig1">Fig. 1 </a>test.png</figcaption></figure>

---start mg img5 with ID, caption, and figure
[??test.png|#fig1]

---start html img5
<figure><a href="test.png" target="_self"><img src="test.png" alt="fig1" id="fig1"></a><figcaption><a href="#fig1">Fig. 1 </a>test.png</figcaption></figure>

---start mg img5 with ID, caption, and figure [ja]
[??test.png|#fig1]

---start html img5
<figure><a href="test.png" target="_self"><img src="test.png" alt="fig1" id="fig1"></a><figcaption><a href="#fig1">図1 </a>test.png</figcaption></figure>

---start mg picture1
[!!!a.png]

---start html picture1
<p><picture><img src="a.png" alt="a.png"></picture></p>

---start mg picture2
[!!!a.png x]

---start html picture2
<p><picture><img src="a.png" alt="x"></picture></p>

---start mg img srcset
[!{a.png|400w|b.png|800w}def.png x]

---start html img srcset
<p><img srcset="a.png 400w, b.png 800w" src="def.png" alt="x"></p>

---start mg picture srcset
[!!!{a.png|400w}{b.png|800w}def.png x]

---start html picture srcset
<p><picture><source srcset="a.png 400w"> <source srcset="b.png 800w"><img src="def.png" alt="x"></picture></p>

---start mg img with srcset and sizes
[!{400w.png|400w|600w.png|600w|800w.png|800w|1000w.png|1000w|1200w.png|1200w|min1140|570:|min640|50vw:|100vw:}x.png]

---start html img with srcset and sizes
<p><img srcset="400w.png 400w, 600w.png 600w, 800w.png 800w, 1000w.png 1000w, 1200w.png 1200w" sizes="(min-width: 1140px) 570px, (min-width: 640px) 50vw, 100vw" src="x.png" alt="x.png"></p>

---start mg picture with srcset and sizes
[!!!{400w.png|400w|min1140|570:}{600w.png|600w|50vw:}{800w.png|800w|100vw:|}{1000w.png|1000w}x.png]

---start html picture with srcset and sizes
<p><picture><source srcset="400w.png 400w" media="(min-width: 1140px)" sizes="570px"> <source srcset="600w.png 600w" sizes="50vw">  <source srcset="800w.png 800w" sizes="100vw"> <source srcset="1000w.png 1000w"> <img src="x.png" alt="x.png"> </picture></p>

---start mg img with both srcset and sizes
[!{480w.jpg|480w|800w.jpg|800w|max600|480:|800:}x.jpg x]

---start html img with both srcset and sizes
<p><img srcset="480w.jpg 480w, 800w.jpg 800w" sizes="(max-width: 600px) 480px, 800px" src="x.jpg" alt="x"></p>

---end
